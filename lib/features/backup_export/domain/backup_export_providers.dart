import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_data/data/core_data_providers.dart';
import 'backup_service.dart';
import 'export_service.dart';

final FutureProvider<BackupService> backupServiceProvider = FutureProvider<BackupService>((ref) async {
  final expenseRepository = await ref.watch(expenseRepositoryProvider.future);
  final categoryRepository = await ref.watch(categoryRepositoryProvider.future);
  final budgetRepository = await ref.watch(budgetRepositoryProvider.future);
  final settingsRepository = await ref.watch(settingsRepositoryProvider.future);
  return BackupService(expenseRepository, categoryRepository, budgetRepository, settingsRepository);
});

final FutureProvider<ExportService> exportServiceProvider = FutureProvider<ExportService>((ref) async {
  final expenseRepository = await ref.watch(expenseRepositoryProvider.future);
  final categoryRepository = await ref.watch(categoryRepositoryProvider.future);
  return ExportService(expenseRepository, categoryRepository);
});
