import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'budget_repository.dart';
import 'category_repository.dart';
import 'expense_repository.dart';
import 'isar_provider.dart';
import 'settings_repository.dart';

/// Riverpod providers wiring the Isar instance into each repository.
///
/// All four `Provider`s below are `FutureProvider`s because they depend on
/// the async-initialized [isarInstanceProvider]. Presentation-layer code
/// consumes these via `ref.watch(expenseRepositoryProvider.future)` (or
/// `AsyncValue` handling with `ref.watch(expenseRepositoryProvider)`).

final FutureProvider<ExpenseRepository> expenseRepositoryProvider = FutureProvider<ExpenseRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return ExpenseRepository(isar);
});

final FutureProvider<BudgetRepository> budgetRepositoryProvider = FutureProvider<BudgetRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return BudgetRepository(isar);
});

final FutureProvider<CategoryRepository> categoryRepositoryProvider = FutureProvider<CategoryRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return CategoryRepository(isar);
});

final FutureProvider<SettingsRepository> settingsRepositoryProvider = FutureProvider<SettingsRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return SettingsRepository(isar);
});
