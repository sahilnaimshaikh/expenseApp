import 'package:isar/isar.dart';
import 'package:workmanager/workmanager.dart';

import '../../core_data/data/budget_repository.dart';
import '../../core_data/data/category_repository.dart';
import '../../core_data/data/expense_repository.dart';
import '../../core_data/data/isar_provider.dart';
import '../../core_data/data/settings_repository.dart';
import 'backup_service.dart';

const String nightlyBackupTaskName = 'nightlyBackupTask';

/// workmanager's top-level callback dispatcher. Must be a top-level (or
/// static) function per workmanager's plugin contract — it runs in a
/// separate background isolate with no access to the app's Riverpod
/// ProviderScope, so it constructs its own minimal dependency chain
/// directly against Isar rather than reading providers.
@pragma('vm:entry-point')
void backgroundBackupDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == nightlyBackupTaskName) {
      final isar = await Isar.getInstance() ?? await _openIsarForBackground();
      final backupService = BackupService(
        ExpenseRepository(isar),
        CategoryRepository(isar),
        BudgetRepository(isar),
        SettingsRepository(isar),
      );
      await backupService.runScheduledBackup();
    }
    return true;
  });
}

Future<Isar> _openIsarForBackground() async {
  // Mirrors isar_provider.dart's schema registration. Background isolates
  // need their own Isar.open call since they don't share the foreground
  // isolate's provider-managed instance.
  throw UnimplementedError(
    'Background Isar re-open requires the same directory path as '
    'isar_provider.dart — implement once running on a device with the '
    'Flutter SDK to determine the correct getApplicationDocumentsDirectory() '
    'behavior in a background isolate.',
  );
}

/// Registers the nightly backup as a periodic workmanager task. Called
/// once at app startup (main.dart).
Future<void> registerNightlyBackupTask() async {
  await Workmanager().initialize(backgroundBackupDispatcher);
  await Workmanager().registerPeriodicTask(
    nightlyBackupTaskName,
    nightlyBackupTaskName,
    frequency: const Duration(hours: 24),
  );
}
