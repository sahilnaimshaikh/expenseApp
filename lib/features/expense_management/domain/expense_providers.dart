import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_data/data/core_data_providers.dart';
import 'expense_service.dart';

final FutureProvider<ExpenseService> expenseServiceProvider = FutureProvider<ExpenseService>((ref) async {
  final expenseRepository = await ref.watch(expenseRepositoryProvider.future);
  final categoryRepository = await ref.watch(categoryRepositoryProvider.future);
  return ExpenseService(expenseRepository, categoryRepository);
});
