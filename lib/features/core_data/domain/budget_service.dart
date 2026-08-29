import 'package:decimal/decimal.dart';

import '../data/budget_repository.dart';
import '../data/expense_repository.dart';
import 'budget_status.dart';
import 'models/budget.dart';
import 'models/enums.dart';

/// Thrown when a BudgetService business rule is violated.
class BudgetValidationException implements Exception {
  const BudgetValidationException(this.message);

  final String message;

  @override
  String toString() => 'BudgetValidationException: $message';
}

/// Full budget business logic: amount configuration (Unit 1), status
/// computation, and threshold evaluation (Unit 3).
///
/// See aidlc-docs/construction/budgeting-notifications/functional-design/
/// business-rules.md for BR-14 through BR-19. Per
/// unit-of-work-dependency.md's "Special Case", this single class spans
/// two units by design — [setBudgetAmount] shipped first (Unit 1,
/// needed by onboarding), [recalculate]/[evaluateThresholds]/
/// [updateNotificationThresholds] are added here (Unit 3).
class BudgetService {
  BudgetService(this._budgetRepository, this._expenseRepository);

  final BudgetRepository _budgetRepository;
  final ExpenseRepository _expenseRepository;

  static const List<int> _allThresholds = [50, 75, 90, 100];

  /// BR-7: rejects zero/negative amounts (see Unit 1 functional-design/business-rules.md).
  Future<void> setBudgetAmount({
    required int month,
    required int year,
    required LedgerScope scope,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw const BudgetValidationException('Budget amount must be greater than zero.');
    }

    final existing = await _budgetRepository.getBudget(month, year, scope);
    final budget = existing ?? Budget(month: month, year: year, ledgerScope: scope, budgetAmount: amount);
    budget.budgetAmount = amount;

    await _budgetRepository.upsertBudget(budget);
  }

  Future<void> updateNotificationThresholds({
    required int month,
    required int year,
    required LedgerScope scope,
    required Map<int, bool> thresholdFlags,
  }) async {
    final budget = await _budgetRepository.getBudget(month, year, scope);
    if (budget == null) {
      throw const BudgetValidationException('Set a budget amount before configuring notifications.');
    }

    if (thresholdFlags.containsKey(50)) budget.notify50 = thresholdFlags[50]!;
    if (thresholdFlags.containsKey(75)) budget.notify75 = thresholdFlags[75]!;
    if (thresholdFlags.containsKey(90)) budget.notify90 = thresholdFlags[90]!;
    if (thresholdFlags.containsKey(100)) budget.notify100 = thresholdFlags[100]!;

    await _budgetRepository.upsertBudget(budget);
  }

  /// BR-16: pure computation, never mutates `firedThresholds`. Safe to
  /// call any number of times (e.g. for display refreshes).
  Future<BudgetStatus> recalculate(int month, int year, LedgerScope scope) async {
    final budget = await _budgetRepository.getBudget(month, year, scope);
    final amountSpent = await _sumExpenses(month, year, scope);

    return BudgetStatus(
      month: month,
      year: year,
      ledgerScope: scope,
      budgetAmount: budget?.budgetAmount ?? 0,
      amountSpent: amountSpent,
      hasBudgetConfigured: budget != null,
    );
  }

  Future<BudgetStatus> getBudgetStatus(int month, int year, LedgerScope scope) => recalculate(month, year, scope);

  /// BR-14/BR-15: only the one method that mutates `firedThresholds`.
  /// Returns the thresholds newly crossed by this call (empty if none).
  Future<List<ThresholdCrossing>> evaluateThresholds(int month, int year, LedgerScope scope) async {
    final budget = await _budgetRepository.getBudget(month, year, scope);
    if (budget == null) return const [];

    final status = await recalculate(month, year, scope);
    final enabledMap = {
      50: budget.notify50,
      75: budget.notify75,
      90: budget.notify90,
      100: budget.notify100,
    };

    final newlyFired = <int>[];
    for (final threshold in _allThresholds) {
      final alreadyFired = budget.firedThresholds.contains(threshold);
      final enabled = enabledMap[threshold] ?? false;
      if (!alreadyFired && enabled && status.percentageUsed >= threshold) {
        newlyFired.add(threshold);
      }
    }

    if (newlyFired.isEmpty) return const [];

    budget.firedThresholds = [...budget.firedThresholds, ...newlyFired];
    await _budgetRepository.upsertBudget(budget);

    return newlyFired
        .map((t) => ThresholdCrossing(
              threshold: t,
              month: month,
              year: year,
              ledgerScope: scope,
              percentageUsed: status.percentageUsed,
            ))
        .toList();
  }

  /// BR-18: decimal-safe summation. BR-19: scope-aware filtering.
  Future<double> _sumExpenses(int month, int year, LedgerScope scope) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));

    final expenses = await _expenseRepository.query(ExpenseQueryParams(
      startDate: startDate,
      endDate: endDate,
      expenseType: scope == LedgerScope.combined ? null : scope.toExpenseType(),
      limit: 1000000,
    ));

    var total = Decimal.zero;
    for (final expense in expenses) {
      total += Decimal.parse(expense.amount.toString());
    }
    return total.toDouble();
  }
}

/// Inverse of [ExpenseTypeToLedgerScope] — used by BR-19's scope-aware
/// filtering. Only defined for personal/home; calling on [LedgerScope.combined]
/// is a programming error (combined has no single ExpenseType equivalent).
extension LedgerScopeToExpenseType on LedgerScope {
  ExpenseType toExpenseType() {
    switch (this) {
      case LedgerScope.personal:
        return ExpenseType.personal;
      case LedgerScope.home:
        return ExpenseType.home;
      case LedgerScope.combined:
        throw StateError('LedgerScope.combined has no single ExpenseType equivalent.');
    }
  }
}
