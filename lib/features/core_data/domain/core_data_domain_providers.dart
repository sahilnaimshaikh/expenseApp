import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/core_data_providers.dart';
import 'budget_service.dart';

final FutureProvider<BudgetService> budgetServiceProvider = FutureProvider<BudgetService>((ref) async {
  final budgetRepository = await ref.watch(budgetRepositoryProvider.future);
  final expenseRepository = await ref.watch(expenseRepositoryProvider.future);
  return BudgetService(budgetRepository, expenseRepository);
});
