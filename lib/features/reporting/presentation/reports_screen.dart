import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reports_controller.dart';

/// Reports screen (stories.md US-14 to US-19). Tab-per-report, per
/// functional-design/business-logic-model.md.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsControllerProvider);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(key: Key('reports-tab-monthly'), text: 'Monthly'),
              Tab(key: Key('reports-tab-category'), text: 'Category'),
              Tab(key: Key('reports-tab-personal-home'), text: 'Personal vs Home'),
              Tab(key: Key('reports-tab-top-categories'), text: 'Top Categories'),
              Tab(key: Key('reports-tab-comparison'), text: 'Comparison'),
              Tab(key: Key('reports-tab-utilization'), text: 'Utilization'),
            ],
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _MonthlySpendingTab(monthlySpending: state.monthlySpending),
                  _CategoryTab(categoryBreakdown: state.categoryBreakdown),
                  _PersonalHomeTab(comparison: state.ledgerComparison),
                  _TopCategoriesTab(topCategories: state.topCategories),
                  _ComparisonTab(comparison: state.monthlyComparison),
                  _UtilizationTab(percent: state.budgetUtilizationPercent),
                ],
              ),
      ),
    );
  }
}

class _MonthlySpendingTab extends StatelessWidget {
  const _MonthlySpendingTab({required this.monthlySpending});

  final List monthlySpending;

  @override
  Widget build(BuildContext context) {
    if (monthlySpending.isEmpty) return const Center(child: Text('No data yet.'));
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < monthlySpending.length; i++) FlSpot(i.toDouble(), monthlySpending[i].total)],
          ),
        ],
      ),
      // Unit 7 (US-23): animated chart transitions.
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({required this.categoryBreakdown});

  final List categoryBreakdown;

  @override
  Widget build(BuildContext context) {
    final nonZero = categoryBreakdown.where((c) => c.total > 0).toList();
    if (nonZero.isEmpty) return const Center(child: Text('No spending this month.'));
    return PieChart(
      PieChartData(sections: nonZero.map((c) => PieChartSectionData(value: c.total, title: c.categoryName)).toList()),
      // Unit 7 (US-23): animated chart transitions.
      swapAnimationDuration: const Duration(milliseconds: 300),
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}

class _PersonalHomeTab extends StatelessWidget {
  const _PersonalHomeTab({required this.comparison});

  final dynamic comparison;

  @override
  Widget build(BuildContext context) {
    if (comparison == null) return const Center(child: Text('No data yet.'));
    return Center(
      child: Text('Personal: ₹${comparison.personalTotal.toStringAsFixed(0)}  ·  Home: ₹${comparison.homeTotal.toStringAsFixed(0)}'),
    );
  }
}

class _TopCategoriesTab extends StatelessWidget {
  const _TopCategoriesTab({required this.topCategories});

  final List topCategories;

  @override
  Widget build(BuildContext context) {
    if (topCategories.isEmpty) return const Center(child: Text('No spending this month.'));
    return ListView(
      children: topCategories
          .map<Widget>((c) => ListTile(title: Text(c.categoryName), trailing: Text('₹${c.total.toStringAsFixed(0)}')))
          .toList(),
    );
  }
}

class _ComparisonTab extends StatelessWidget {
  const _ComparisonTab({required this.comparison});

  final dynamic comparison;

  @override
  Widget build(BuildContext context) {
    if (comparison == null) return const Center(child: Text('No data yet.'));
    return Column(
      children: [
        ListTile(title: const Text('This month'), trailing: Text('₹${comparison.currentMonthTotal.toStringAsFixed(0)}')),
        ...comparison.priorMonths.map<Widget>((m) => ListTile(
              title: Text('${m.month}/${m.year}'),
              trailing: Text('₹${m.total.toStringAsFixed(0)}'),
            )),
      ],
    );
  }
}

class _UtilizationTab extends StatelessWidget {
  const _UtilizationTab({required this.percent});

  final double? percent;

  @override
  Widget build(BuildContext context) {
    if (percent == null) return const Center(child: Text('No data yet.'));
    return Center(
      child: Text(
        '${percent!.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 32,
          color: percent! > 100 ? Theme.of(context).colorScheme.error : null,
        ),
      ),
    );
  }
}
