import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_data/domain/models/enums.dart';
import '../domain/report_providers.dart';
import '../domain/report_results.dart';

class ReportsState {
  const ReportsState({
    this.monthlySpending = const [],
    this.categoryBreakdown = const [],
    this.ledgerComparison,
    this.topCategories = const [],
    this.monthlyComparison,
    this.budgetUtilizationPercent,
    this.isLoading = true,
  });

  final List<MonthlyTotal> monthlySpending;
  final List<CategoryTotal> categoryBreakdown;
  final LedgerComparison? ledgerComparison;
  final List<CategoryTotal> topCategories;
  final MonthlyComparisonResult? monthlyComparison;
  final double? budgetUtilizationPercent;
  final bool isLoading;

  ReportsState copyWith({
    List<MonthlyTotal>? monthlySpending,
    List<CategoryTotal>? categoryBreakdown,
    LedgerComparison? ledgerComparison,
    List<CategoryTotal>? topCategories,
    MonthlyComparisonResult? monthlyComparison,
    double? budgetUtilizationPercent,
    bool? isLoading,
  }) {
    return ReportsState(
      monthlySpending: monthlySpending ?? this.monthlySpending,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      ledgerComparison: ledgerComparison ?? this.ledgerComparison,
      topCategories: topCategories ?? this.topCategories,
      monthlyComparison: monthlyComparison ?? this.monthlyComparison,
      budgetUtilizationPercent: budgetUtilizationPercent ?? this.budgetUtilizationPercent,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Drives the Reports screen (US-14 to US-19). Loads all 6 reports for the
/// current month concurrently.
class ReportsController extends Notifier<ReportsState> {
  @override
  ReportsState build() {
    Future.microtask(load);
    return const ReportsState();
  }

  Future<void> load({LedgerScope scope = LedgerScope.combined}) async {
    state = state.copyWith(isLoading: true);
    final service = await ref.read(reportServiceProvider.future);
    final now = DateTime.now();

    final results = await Future.wait([
      service.monthlySpending(6, scope: scope),
      service.categoryAnalysis(now.month, now.year, scope: scope),
      service.personalVsHome(now.month, now.year),
      service.topCategories(now.month, now.year, scope: scope),
      service.monthlyComparison(now.month, now.year, scope: scope),
      service.budgetUtilization(now.month, now.year, scope: scope),
    ]);

    state = state.copyWith(
      monthlySpending: results[0] as List<MonthlyTotal>,
      categoryBreakdown: results[1] as List<CategoryTotal>,
      ledgerComparison: results[2] as LedgerComparison,
      topCategories: results[3] as List<CategoryTotal>,
      monthlyComparison: results[4] as MonthlyComparisonResult,
      budgetUtilizationPercent: results[5] as double,
      isLoading: false,
    );
  }
}

final NotifierProvider<ReportsController, ReportsState> reportsControllerProvider =
    NotifierProvider<ReportsController, ReportsState>(ReportsController.new);
