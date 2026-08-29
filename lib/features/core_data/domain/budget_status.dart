import 'models/enums.dart';

/// Transient, computed budget status for a given month/year/ledgerScope.
///
/// Lives alongside [BudgetService] (not in a later unit's folder) because
/// it is that service's own return type — see
/// aidlc-docs/construction/budgeting-notifications/functional-design/domain-entities.md
/// for field definitions and BR-17 (divide-by-zero guard via
/// [hasBudgetConfigured]).
class BudgetStatus {
  const BudgetStatus({
    required this.month,
    required this.year,
    required this.ledgerScope,
    required this.budgetAmount,
    required this.amountSpent,
    required this.hasBudgetConfigured,
  });

  final int month;
  final int year;
  final LedgerScope ledgerScope;
  final double budgetAmount;
  final double amountSpent;
  final bool hasBudgetConfigured;

  double get remainingAmount => budgetAmount - amountSpent;

  /// BR-17: 0 when no budget is configured, rather than a NaN/Infinity
  /// divide-by-zero result.
  double get percentageUsed => budgetAmount == 0 ? 0 : (amountSpent / budgetAmount) * 100;
}

/// A single threshold that was newly crossed (per BR-14, at most once per
/// month per threshold).
class ThresholdCrossing {
  const ThresholdCrossing({
    required this.threshold,
    required this.month,
    required this.year,
    required this.ledgerScope,
    required this.percentageUsed,
  });

  final int threshold;
  final int month;
  final int year;
  final LedgerScope ledgerScope;
  final double percentageUsed;
}
