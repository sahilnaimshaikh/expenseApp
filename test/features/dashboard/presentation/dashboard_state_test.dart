import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/features/dashboard/presentation/dashboard_controller.dart';
import 'package:expense_tracker/features/reporting/domain/report_results.dart';

void main() {
  group('DashboardState', () {
    test('copyWith preserves unspecified fields and overrides specified ones', () {
      const initial = DashboardState(
        recentExpenses: [],
        categoryBreakdown: [CategoryTotal(categoryId: 1, categoryName: 'Food', total: 100)],
        isLoading: true,
      );

      final updated = initial.copyWith(isLoading: false);

      expect(updated.isLoading, isFalse);
      expect(updated.categoryBreakdown, initial.categoryBreakdown);
    });

    test('defaults to empty lists and isLoading=true', () {
      const state = DashboardState();
      expect(state.categoryBreakdown, isEmpty);
      expect(state.monthlyTrend, isEmpty);
      expect(state.recentExpenses, isEmpty);
      expect(state.isLoading, isTrue);
    });
  });
}
