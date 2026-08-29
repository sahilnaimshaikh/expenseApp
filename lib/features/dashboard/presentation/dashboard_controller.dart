import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_data/domain/budget_status.dart';
import '../../core_data/domain/core_data_domain_providers.dart';
import '../../core_data/domain/models/enums.dart';
import '../../core_data/domain/models/expense.dart';
import '../../expense_management/domain/expense_providers.dart';
import '../../reporting/domain/report_providers.dart';
import '../../reporting/domain/report_results.dart';

class DashboardState {
  const DashboardState({
    this.combinedStatus,
    this.personalStatus,
    this.homeStatus,
    this.recentExpenses = const [],
    this.categoryBreakdown = const [],
    this.monthlyTrend = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final BudgetStatus? combinedStatus;
  final BudgetStatus? personalStatus;
  final BudgetStatus? homeStatus;
  final List<Expense> recentExpenses;

  /// Real category breakdown via ReportService.categoryAnalysis(), as of
  /// Unit 5 — supersedes the Unit 4 placeholder that computed this from
  /// [recentExpenses] alone.
  final List<CategoryTotal> categoryBreakdown;

  /// Real monthly trend via ReportService.monthlySpending(), as of Unit 5.
  final List<MonthlyTotal> monthlyTrend;

  final bool isLoading;
  final String? errorMessage;

  DashboardState copyWith({
    BudgetStatus? combinedStatus,
    BudgetStatus? personalStatus,
    BudgetStatus? homeStatus,
    List<Expense>? recentExpenses,
    List<CategoryTotal>? categoryBreakdown,
    List<MonthlyTotal>? monthlyTrend,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      combinedStatus: combinedStatus ?? this.combinedStatus,
      personalStatus: personalStatus ?? this.personalStatus,
      homeStatus: homeStatus ?? this.homeStatus,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    Future.microtask(load);
    return const DashboardState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final budgetService = await ref.read(budgetServiceProvider.future);
      final expenseService = await ref.read(expenseServiceProvider.future);
      final reportService = await ref.read(reportServiceProvider.future);
      final now = DateTime.now();

      // Concurrent load pattern (nfr-design-patterns.md) — NFR-1.
      final results = await Future.wait([
        budgetService.getBudgetStatus(now.month, now.year, LedgerScope.combined),
        budgetService.getBudgetStatus(now.month, now.year, LedgerScope.personal),
        budgetService.getBudgetStatus(now.month, now.year, LedgerScope.home),
        expenseService.listExpenses(limit: 5),
        reportService.categoryAnalysis(now.month, now.year),
        reportService.monthlySpending(6),
      ]);

      state = state.copyWith(
        combinedStatus: results[0] as BudgetStatus,
        personalStatus: results[1] as BudgetStatus,
        homeStatus: results[2] as BudgetStatus,
        recentExpenses: results[3] as List<Expense>,
        categoryBreakdown: results[4] as List<CategoryTotal>,
        monthlyTrend: results[5] as List<MonthlyTotal>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Couldn't load your dashboard.");
    }
  }
}

final NotifierProvider<DashboardController, DashboardState> dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(DashboardController.new);
