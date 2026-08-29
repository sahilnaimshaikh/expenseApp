import 'package:decimal/decimal.dart';

import '../../core_data/data/category_repository.dart';
import '../../core_data/data/expense_repository.dart';
import '../../core_data/domain/budget_service.dart';
import '../../core_data/domain/models/enums.dart';
import '../../core_data/domain/models/expense.dart';
import 'report_results.dart';

/// Read-only aggregation service for all 6 report types (US-14 to US-19).
///
/// Per Application Design's services.md, this is the one domain service
/// permitted a read-only call into another domain service (BudgetService,
/// for [budgetUtilization] only — BR-26). All other methods query
/// ExpenseRepository directly and aggregate here.
class ReportService {
  ReportService(this._expenseRepository, this._categoryRepository, this._budgetService);

  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;
  final BudgetService _budgetService;

  /// US-14. BR-24: includes months with zero spend as explicit entries.
  Future<List<MonthlyTotal>> monthlySpending(int monthsBack, {LedgerScope scope = LedgerScope.combined}) async {
    final now = DateTime.now();
    final results = <MonthlyTotal>[];

    for (var i = monthsBack - 1; i >= 0; i--) {
      final target = DateTime(now.year, now.month - i, 1);
      final total = await _sumForMonth(target.month, target.year, scope);
      results.add(MonthlyTotal(month: target.month, year: target.year, total: total));
    }

    return results;
  }

  /// US-15. BR-24: includes categories with zero spend in the period.
  Future<List<CategoryTotal>> categoryAnalysis(int month, int year, {LedgerScope scope = LedgerScope.combined}) async {
    final categories = await _categoryRepository.getAll();
    final expenses = await _expensesForMonth(month, year, scope);

    final totalsByCategory = <int, Decimal>{};
    for (final category in categories) {
      totalsByCategory[category.id] = Decimal.zero;
    }
    for (final expense in expenses) {
      final current = totalsByCategory[expense.categoryId] ?? Decimal.zero;
      totalsByCategory[expense.categoryId] = current + Decimal.parse(expense.amount.toString());
    }

    return categories
        .map((c) => CategoryTotal(
              categoryId: c.id,
              categoryName: c.name,
              total: (totalsByCategory[c.id] ?? Decimal.zero).toDouble(),
            ))
        .toList();
  }

  /// US-16. BR-24: zero-value ledger shown as 0, not omitted.
  Future<LedgerComparison> personalVsHome(int month, int year) async {
    final personalTotal = await _sumForMonth(month, year, LedgerScope.personal);
    final homeTotal = await _sumForMonth(month, year, LedgerScope.home);
    return LedgerComparison(personalTotal: personalTotal, homeTotal: homeTotal);
  }

  /// US-17. BR-25: stable tie-break by categoryId ascending.
  Future<List<CategoryTotal>> topCategories(int month, int year, {LedgerScope scope = LedgerScope.combined, int limit = 5}) async {
    final all = await categoryAnalysis(month, year, scope: scope);
    final sorted = [...all]..sort((a, b) {
        final byTotal = b.total.compareTo(a.total);
        return byTotal != 0 ? byTotal : a.categoryId.compareTo(b.categoryId);
      });
    return sorted.take(limit).toList();
  }

  /// US-18.
  Future<MonthlyComparisonResult> monthlyComparison(int month, int year, {int monthsBack = 3, LedgerScope scope = LedgerScope.combined}) async {
    final currentTotal = await _sumForMonth(month, year, scope);
    final priorMonths = <MonthlyTotal>[];

    for (var i = 1; i <= monthsBack; i++) {
      final target = DateTime(year, month - i, 1);
      final total = await _sumForMonth(target.month, target.year, scope);
      priorMonths.add(MonthlyTotal(month: target.month, year: target.year, total: total));
    }

    return MonthlyComparisonResult(currentMonthTotal: currentTotal, priorMonths: priorMonths);
  }

  /// US-19. BR-26: pure delegation to BudgetService — no reimplemented math.
  Future<double> budgetUtilization(int month, int year, {LedgerScope scope = LedgerScope.combined}) async {
    final status = await _budgetService.getBudgetStatus(month, year, scope);
    return status.percentageUsed;
  }

  Future<List<Expense>> _expensesForMonth(int month, int year, LedgerScope scope) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));

    return _expenseRepository.query(ExpenseQueryParams(
      startDate: startDate,
      endDate: endDate,
      expenseType: scope == LedgerScope.combined ? null : scope.toExpenseType(),
      limit: 1000000,
    ));
  }

  Future<double> _sumForMonth(int month, int year, LedgerScope scope) async {
    final expenses = await _expensesForMonth(month, year, scope);
    var total = Decimal.zero;
    for (final expense in expenses) {
      total += Decimal.parse(expense.amount.toString());
    }
    return total.toDouble();
  }
}
