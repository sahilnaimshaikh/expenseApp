import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, setUp, tearDown, setUpAll, tearDownAll, expect, expectLater;
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/backup_export/domain/backup_service.dart';
import 'package:expense_tracker/features/core_data/data/budget_repository.dart';
import 'package:expense_tracker/features/core_data/data/category_repository.dart';
import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/data/settings_repository.dart';
import 'package:expense_tracker/features/core_data/domain/models/budget.dart';
import 'package:expense_tracker/features/core_data/domain/models/category.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/core_data/domain/models/expense.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('BackupService', () {
    late Directory tempDir;
    late Isar sourceIsar;
    late BackupService sourceService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('backup_test_');
      sourceIsar = await openTestIsar();
      sourceService = BackupService(
        ExpenseRepository(sourceIsar),
        CategoryRepository(sourceIsar),
        BudgetRepository(sourceIsar),
        SettingsRepository(sourceIsar),
        backupsDirectoryOverride: tempDir.path,
      );
    });

    tearDown(() async {
      await sourceIsar.close(deleteFromDisk: true);
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    Future<void> seedSourceData(Isar isar) async {
      final category = Category(name: 'Food', icon: 'x', color: '#000', isDefault: true);
      final categoryRepo = CategoryRepository(isar);
      final created = await categoryRepo.create(category);

      await ExpenseRepository(isar).create(Expense(
        amount: 123.45,
        categoryId: created.id,
        expenseType: ExpenseType.personal,
        date: DateTime(2026, 5, 1),
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 1),
        description: 'Lunch',
        tags: ['work'],
      ));

      await BudgetRepository(isar).upsertBudget(
        Budget(month: 5, year: 2026, ledgerScope: LedgerScope.combined, budgetAmount: 10000),
      );

      final settingsRepo = SettingsRepository(isar);
      final settings = await settingsRepo.getSettings();
      settings.currency = 'USD';
      await settingsRepo.updateSettings(settings);
    }

    test('createManualBackup produces a ZIP file at the backups directory', () async {
      await seedSourceData(sourceIsar);
      final file = await sourceService.createManualBackup(null);

      expect(await file.exists(), isTrue);
      expect(file.path.endsWith('.zip'), isTrue);
    });

    // BR-29: restore aborts and leaves existing data untouched on a
    // corrupted/invalid file.
    test('restoreFromBackup rejects a non-ZIP file without touching existing data', () async {
      await seedSourceData(sourceIsar);
      final expensesBefore = await ExpenseRepository(sourceIsar).getAll();

      final badFile = File('${tempDir.path}/not_a_backup.zip');
      await badFile.writeAsBytes([1, 2, 3, 4]);

      await expectLater(
        sourceService.restoreFromBackup(badFile),
        throwsA(isA<BackupException>()),
      );

      final expensesAfter = await ExpenseRepository(sourceIsar).getAll();
      expect(expensesAfter.length, expensesBefore.length);
    });

    // PBT-02 flagship round-trip property for this unit: backup then
    // restore into a fresh database yields equal data.
    test('backup then restore into a fresh database round-trips all data', () async {
      await seedSourceData(sourceIsar);
      final backupFile = await sourceService.createManualBackup(null);

      final targetIsar = await openTestIsar();
      try {
        final targetService = BackupService(
          ExpenseRepository(targetIsar),
          CategoryRepository(targetIsar),
          BudgetRepository(targetIsar),
          SettingsRepository(targetIsar),
          backupsDirectoryOverride: tempDir.path,
        );

        await targetService.restoreFromBackup(backupFile);

        final restoredExpenses = await ExpenseRepository(targetIsar).getAll();
        final restoredCategories = await CategoryRepository(targetIsar).getAll();
        final restoredBudgets = await BudgetRepository(targetIsar).getAll();
        final restoredSettings = await SettingsRepository(targetIsar).getSettings();

        expect(restoredExpenses, hasLength(1));
        expect(restoredExpenses.single.amount, 123.45);
        expect(restoredExpenses.single.description, 'Lunch');
        expect(restoredExpenses.single.tags, ['work']);

        expect(restoredCategories, hasLength(1));
        expect(restoredCategories.single.name, 'Food');

        expect(restoredBudgets, hasLength(1));
        expect(restoredBudgets.single.budgetAmount, 10000);

        expect(restoredSettings.currency, 'USD');
      } finally {
        await targetIsar.close(deleteFromDisk: true);
      }
    });

    // BR-28: retention keeps only the most recent 7 automatic backups.
    test('pruneOldBackups keeps only the 7 most recent automatic backups', () async {
      final backupsDir = Directory('${tempDir.path}/backups');
      await backupsDir.create(recursive: true);

      for (var i = 0; i < 10; i++) {
        final file = File('${backupsDir.path}/auto_backup_${1000 + i}.zip');
        await file.writeAsBytes([0]);
      }
      // A manual backup should never be pruned.
      final manualFile = File('${backupsDir.path}/expense_tracker_backup_9999.zip');
      await manualFile.writeAsBytes([0]);

      await sourceService.pruneOldBackups();

      final remaining = backupsDir.listSync().whereType<File>().map((f) => f.path).toList();
      final autoRemaining = remaining.where((p) => p.contains('auto_backup_'));
      expect(autoRemaining.length, 7);
      expect(remaining.any((p) => p.contains('expense_tracker_backup_9999')), isTrue);
    });
  });
}
