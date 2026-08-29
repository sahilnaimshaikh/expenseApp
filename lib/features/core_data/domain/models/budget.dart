import 'package:isar/isar.dart';

import 'enums.dart';

part 'budget.g.dart';

/// A monthly budget row, scoped to Combined, Personal, or Home.
///
/// Invariant: at most one row per (month, year, ledgerScope) — enforced by
/// the composite unique index below (defense-in-depth alongside the
/// BudgetService-level check added in Unit 3).
@collection
class Budget {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('year'), CompositeIndex('ledgerScope')], unique: true)
  int month;

  int year;

  @enumerated
  LedgerScope ledgerScope;

  double budgetAmount;

  bool notify50;

  bool notify75;

  bool notify90;

  bool notify100;

  /// Thresholds (from [50, 75, 90, 100]) already notified for this
  /// month/year/ledgerScope, per BR-14 (fire-at-most-once-per-month).
  /// Added in Unit 3 — see functional-design/domain-entities.md
  /// "Threshold-Fired Tracking" for why this lives on Budget rather than
  /// a separate entity.
  List<int> firedThresholds;

  Budget({
    required this.month,
    required this.year,
    required this.ledgerScope,
    required this.budgetAmount,
    this.notify50 = true,
    this.notify75 = true,
    this.notify90 = true,
    this.notify100 = true,
    this.firedThresholds = const <int>[],
  });
}
