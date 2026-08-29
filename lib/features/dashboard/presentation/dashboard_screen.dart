import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../reporting/domain/report_results.dart';
import 'dashboard_controller.dart';

/// Dashboard (stories.md US-10) — the first screen after onboarding.
/// Aggregates data from Units 1-3, 5; introduces no new business logic.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      floatingActionButton: FloatingActionButton(
        key: const Key('dashboard-quick-add-fab'),
        onPressed: () => context.push('/expenses/add'),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Hello!', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _BudgetCard(status: state.combinedStatus),
                  const SizedBox(height: 16),
                  Card(
                    key: const Key('dashboard-personal-home-summary'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: Text('Personal: ₹${state.personalStatus?.amountSpent.toStringAsFixed(0) ?? 0}')),
                          Expanded(child: Text('Home: ₹${state.homeStatus?.amountSpent.toStringAsFixed(0) ?? 0}')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CategoryChart(breakdown: state.categoryBreakdown),
                  const SizedBox(height: 16),
                  _TrendChart(trend: state.monthlyTrend),
                  const SizedBox(height: 16),
                  Text('Recent Expenses', style: Theme.of(context).textTheme.titleMedium),
                  if (state.recentExpenses.isEmpty)
                    const Padding(padding: EdgeInsets.all(16), child: Text('No expenses yet.'))
                  else
                    Column(
                      key: const Key('dashboard-recent-expenses-list'),
                      children: state.recentExpenses
                          .take(5)
                          .map((e) => ListTile(
                                title: Text('₹${e.amount.toStringAsFixed(2)}'),
                                subtitle: Text(e.description ?? e.expenseType.name),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.status});

  final dynamic status;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('dashboard-budget-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: status == null || status.hasBudgetConfigured == false
            ? const Text('No budget set for this month.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Budget: ₹${status.budgetAmount.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: (status.percentageUsed / 100).clamp(0, 1)),
                  const SizedBox(height: 8),
                  Text('Spent: ₹${status.amountSpent.toStringAsFixed(0)} · Remaining: ₹${status.remainingAmount.toStringAsFixed(0)}'),
                ],
              ),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.breakdown});

  /// Real category totals via ReportService.categoryAnalysis() (Unit 5) —
  /// includes zero-spend categories per BR-24, filtered out here purely
  /// for chart legibility (a 0-value pie slice renders as nothing anyway).
  final List<CategoryTotal> breakdown;

  @override
  Widget build(BuildContext context) {
    final nonZero = breakdown.where((c) => c.total > 0).toList();
    if (nonZero.isEmpty) {
      return const SizedBox(key: Key('dashboard-category-chart'), height: 0);
    }
    return SizedBox(
      key: const Key('dashboard-category-chart'),
      height: 160,
      child: PieChart(
        PieChartData(
          sections: nonZero.map((c) => PieChartSectionData(value: c.total, title: c.categoryName)).toList(),
        ),
        // Unit 7 (US-23): animate instead of snapping instantly, per
        // PRD Section 11 "Animated charts".
        swapAnimationDuration: const Duration(milliseconds: 300),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.trend});

  /// Real monthly totals via ReportService.monthlySpending() (Unit 5),
  /// already chronologically ordered.
  final List<MonthlyTotal> trend;

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return const SizedBox(key: Key('dashboard-trend-chart'), height: 0);
    }
    return SizedBox(
      key: const Key('dashboard-trend-chart'),
      height: 160,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < trend.length; i++) FlSpot(i.toDouble(), trend[i].total),
              ],
            ),
          ],
        ),
        // Unit 7 (US-23): animate instead of snapping instantly.
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }
}
