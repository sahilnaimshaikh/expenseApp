import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core_data/data/budget_repository.dart';
import '../../core_data/data/category_repository.dart';
import '../../core_data/data/expense_repository.dart';
import '../../core_data/data/settings_repository.dart';
import '../../core_data/domain/models/budget.dart';
import '../../core_data/domain/models/category.dart';
import '../../core_data/domain/models/enums.dart';
import '../../core_data/domain/models/expense.dart';
import '../../core_data/domain/models/settings.dart';
import 'backup_manifest.dart';

/// Thrown when a backup archive fails validation (BR-29) or another
/// backup/restore operation fails.
class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => 'BackupException: $message';
}

/// Backup/restore business logic (US-20). See
/// aidlc-docs/construction/backup-export-settings/functional-design/
/// business-rules.md for BR-27 through BR-29.
///
/// Kept separate from [ExportService] per Application Design's Q6
/// decision — backup/restore has different triggers (scheduled + manual)
/// and different consumers (restore reloads into Isar) than export
/// (one-way, human-readable, on-demand only).
class BackupService {
  BackupService(
    this._expenseRepository,
    this._categoryRepository,
    this._budgetRepository,
    this._settingsRepository, {
    String? backupsDirectoryOverride,
  }) : _backupsDirectoryOverride = backupsDirectoryOverride;

  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;

  /// Test/injection seam: when set, [_backupsDirectory] uses this path
  /// instead of calling `path_provider` (which requires a platform
  /// channel unavailable in plain Dart unit tests).
  final String? _backupsDirectoryOverride;
  final BudgetRepository _budgetRepository;
  final SettingsRepository _settingsRepository;

  static const String _appVersion = '0.1.0';
  static const int _automaticBackupRetentionCount = 7; // BR-28

  /// US-20.2: manual, on-demand backup to a ZIP archive.
  Future<File> createManualBackup(String? destinationPath) async {
    final archiveBytes = await _buildArchive();
    final directory = destinationPath ?? (await _backupsDirectory()).path;
    final fileName = 'expense_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.zip';

    return _writeAtomically(p.join(directory, fileName), archiveBytes);
  }

  /// US-20.1: automatic silent nightly backup to app-private storage,
  /// followed by pruning (BR-28). Triggered by the platform scheduler
  /// registered in NFR Design (workmanager) — this method itself has no
  /// scheduling concern, only the backup+prune logic.
  Future<void> runScheduledBackup() async {
    final backupsDir = await _backupsDirectory();
    final archiveBytes = await _buildArchive();
    final fileName = 'auto_backup_${DateTime.now().millisecondsSinceEpoch}.zip';

    await _writeAtomically(p.join(backupsDir.path, fileName), archiveBytes);
    await pruneOldBackups();
  }

  /// BR-28: keeps only the most recent [_automaticBackupRetentionCount]
  /// automatic backups; never touches manual backups (distinguished by
  /// the `auto_backup_` filename prefix).
  Future<void> pruneOldBackups() async {
    final backupsDir = await _backupsDirectory();
    if (!await backupsDir.exists()) return;

    final autoBackups = backupsDir
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith('auto_backup_'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path)); // filenames embed timestamp, so lexical sort = chronological

    if (autoBackups.length <= _automaticBackupRetentionCount) return;

    for (final file in autoBackups.skip(_automaticBackupRetentionCount)) {
      await file.delete();
    }
  }

  /// US-20.3/US-20.4: BR-29 — validates before mutating anything. Restore
  /// is all-or-nothing per collection via each repository's `replaceAll`
  /// (each already transactional; a full multi-collection atomic restore
  /// would additionally require a single Isar instance-wide transaction,
  /// noted as a follow-up if cross-collection atomicity proves necessary
  /// during Build and Test).
  Future<void> restoreFromBackup(File backupFile) async {
    Archive archive;
    try {
      final bytes = await backupFile.readAsBytes();
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw const BackupException('This file is not a valid backup archive.');
    }

    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) {
      throw const BackupException('This backup file is missing its manifest and cannot be restored.');
    }

    Map<String, dynamic> manifestJson;
    try {
      manifestJson = jsonDecode(utf8.decode(manifestFile.content as List<int>)) as Map<String, dynamic>;
    } catch (e) {
      throw const BackupException('This backup file is corrupted and cannot be restored.');
    }

    final manifest = BackupManifest.tryParse(manifestJson);
    if (manifest == null) {
      throw const BackupException('This backup file is corrupted and cannot be restored.');
    }

    final expenses = _decodeEntities(archive, 'expenses.json', _expenseFromJson);
    final categories = _decodeEntities(archive, 'categories.json', _categoryFromJson);
    final budgets = _decodeEntities(archive, 'budgets.json', _budgetFromJson);
    final settingsFile = archive.findFile('settings.json');

    if (expenses == null || categories == null || budgets == null || settingsFile == null) {
      throw const BackupException('This backup file is missing required data and cannot be restored.');
    }

    // All validation above completes before any Isar write — BR-29.
    await _expenseRepository.replaceAll(expenses);
    await _categoryRepository.replaceAll(categories);
    await _budgetRepository.replaceAll(budgets);

    final settingsJson = jsonDecode(utf8.decode(settingsFile.content as List<int>)) as Map<String, dynamic>;
    await _settingsRepository.updateSettings(_settingsFromJson(settingsJson));
  }

  Future<List<int>> _buildArchive() async {
    final expenses = await _expenseRepository.getAll();
    final categories = await _categoryRepository.getAll();
    final budgets = await _budgetRepository.getAll();
    final settings = await _settingsRepository.getSettings();

    final manifest = BackupManifest(
      createdAt: DateTime.now(),
      appVersion: _appVersion,
      expenseCount: expenses.length,
      categoryCount: categories.length,
      budgetCount: budgets.length,
    );

    final archive = Archive();
    archive.addFile(_jsonArchiveFile('manifest.json', manifest.toJson()));
    archive.addFile(_jsonArchiveFile('expenses.json', expenses.map(_expenseToJson).toList()));
    archive.addFile(_jsonArchiveFile('categories.json', categories.map(_categoryToJson).toList()));
    archive.addFile(_jsonArchiveFile('budgets.json', budgets.map(_budgetToJson).toList()));
    archive.addFile(_jsonArchiveFile('settings.json', _settingsToJson(settings)));

    return ZipEncoder().encode(archive) ?? [];
  }

  ArchiveFile _jsonArchiveFile(String name, Object data) {
    final bytes = utf8.encode(jsonEncode(data));
    return ArchiveFile(name, bytes.length, bytes);
  }

  List<T>? _decodeEntities<T>(Archive archive, String fileName, T Function(Map<String, dynamic>) fromJson) {
    final file = archive.findFile(fileName);
    if (file == null) return null;
    try {
      final list = jsonDecode(utf8.decode(file.content as List<int>)) as List<dynamic>;
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  /// BR-31: writes to a temp path first, then renames — a crash/failure
  /// mid-write never leaves a partially-written file at [finalPath].
  Future<File> _writeAtomically(String finalPath, List<int> bytes) async {
    final tempPath = '$finalPath.tmp';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes);
    return tempFile.rename(finalPath);
  }

  Future<Directory> _backupsDirectory() async {
    final basePath = _backupsDirectoryOverride ?? (await getApplicationDocumentsDirectory()).path;
    final backupsDir = Directory(p.join(basePath, 'backups'));
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }
    return backupsDir;
  }

  Map<String, dynamic> _expenseToJson(Expense e) => {
        'id': e.id,
        'amount': e.amount,
        'categoryId': e.categoryId,
        'expenseType': e.expenseType.name,
        'description': e.description,
        'paymentMethod': e.paymentMethod?.name,
        'tags': e.tags,
        'date': e.date.toIso8601String(),
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      };

  Expense _expenseFromJson(Map<String, dynamic> json) {
    final expense = Expense(
      amount: json['amount'] as double,
      categoryId: json['categoryId'] as int,
      expenseType: ExpenseType.values.byName(json['expenseType'] as String),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      description: json['description'] as String?,
      paymentMethod: json['paymentMethod'] == null ? null : PaymentMethod.values.byName(json['paymentMethod'] as String),
      tags: (json['tags'] as List<dynamic>).cast<String>(),
    );
    expense.id = json['id'] as int;
    return expense;
  }

  Map<String, dynamic> _categoryToJson(Category c) => {
        'id': c.id,
        'name': c.name,
        'icon': c.icon,
        'color': c.color,
        'isDefault': c.isDefault,
      };

  Category _categoryFromJson(Map<String, dynamic> json) {
    final category = Category(
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      isDefault: json['isDefault'] as bool,
    );
    category.id = json['id'] as int;
    return category;
  }

  Map<String, dynamic> _budgetToJson(Budget b) => {
        'id': b.id,
        'month': b.month,
        'year': b.year,
        'ledgerScope': b.ledgerScope.name,
        'budgetAmount': b.budgetAmount,
        'notify50': b.notify50,
        'notify75': b.notify75,
        'notify90': b.notify90,
        'notify100': b.notify100,
        'firedThresholds': b.firedThresholds,
      };

  Budget _budgetFromJson(Map<String, dynamic> json) {
    final budget = Budget(
      month: json['month'] as int,
      year: json['year'] as int,
      ledgerScope: LedgerScope.values.byName(json['ledgerScope'] as String),
      budgetAmount: json['budgetAmount'] as double,
      notify50: json['notify50'] as bool,
      notify75: json['notify75'] as bool,
      notify90: json['notify90'] as bool,
      notify100: json['notify100'] as bool,
      firedThresholds: (json['firedThresholds'] as List<dynamic>).cast<int>(),
    );
    budget.id = json['id'] as int;
    return budget;
  }

  Map<String, dynamic> _settingsToJson(Settings s) => {
        'theme': s.theme.name,
        'currency': s.currency,
        'notificationsEnabled': s.notificationsEnabled,
        'backupLocation': s.backupLocation,
        'onboardingComplete': s.onboardingComplete,
      };

  Settings _settingsFromJson(Map<String, dynamic> json) {
    return Settings(
      theme: AppThemeMode.values.byName(json['theme'] as String),
      currency: json['currency'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      backupLocation: json['backupLocation'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool,
    );
  }
}
