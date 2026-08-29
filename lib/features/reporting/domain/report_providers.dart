import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_data/data/core_data_providers.dart';
import '../../core_data/domain/core_data_domain_providers.dart';
import 'report_service.dart';

final FutureProvider<ReportService> reportServiceProvider = FutureProvider<ReportService>((ref) async {
  final expenseRepository = await ref.watch(expenseRepositoryProvider.future);
  final categoryRepository = await ref.watch(categoryRepositoryProvider.future);
  final budgetService = await ref.watch(budgetServiceProvider.future);
  return ReportService(expenseRepository, categoryRepository, budgetService);
});
