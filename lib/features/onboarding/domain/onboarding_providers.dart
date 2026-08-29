import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/domain/category_providers.dart';
import '../../core_data/data/core_data_providers.dart';
import '../../core_data/domain/core_data_domain_providers.dart';
import 'settings_service.dart';

final FutureProvider<SettingsService> settingsServiceProvider = FutureProvider<SettingsService>((ref) async {
  final settingsRepository = await ref.watch(settingsRepositoryProvider.future);
  final categoryService = await ref.watch(categoryServiceProvider.future);
  final budgetService = await ref.watch(budgetServiceProvider.future);
  return SettingsService(settingsRepository, categoryService, budgetService);
});
