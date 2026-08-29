import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_data/data/core_data_providers.dart';
import '../../core_data/domain/models/category.dart';
import 'category_service.dart';

final FutureProvider<CategoryService> categoryServiceProvider = FutureProvider<CategoryService>((ref) async {
  final categoryRepository = await ref.watch(categoryRepositoryProvider.future);
  final expenseRepository = await ref.watch(expenseRepositoryProvider.future);
  return CategoryService(categoryRepository, expenseRepository);
});

/// All categories (default + custom), for picker widgets (e.g. the Add
/// Expense category dropdown). Assumes defaults have already been seeded
/// during onboarding — does not call [CategoryService.ensureDefaultsSeeded]
/// itself, keeping this a pure read.
final FutureProvider<List<Category>> allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoryRepository = await ref.watch(categoryRepositoryProvider.future);
  return categoryRepository.getAll();
});
