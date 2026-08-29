import 'package:isar/isar.dart';

import 'enums.dart';

part 'expense.g.dart';

/// A single expense record.
///
/// See aidlc-docs/construction/core-data-categories/functional-design/domain-entities.md
/// for the full field contract and invariants (BR-7: amount must be > 0).
@collection
class Expense {
  Id id = Isar.autoIncrement;

  /// Stored as double per the PRD schema. All summation/percentage
  /// arithmetic performed by later units MUST use the `decimal` package
  /// (see tech-stack-decisions.md) and only convert to double at this
  /// storage boundary.
  double amount;

  @Index()
  int categoryId;

  @Index()
  @enumerated
  ExpenseType expenseType;

  String? description;

  @Index()
  @Enumerated(EnumType.ordinal32)
  PaymentMethod? paymentMethod;

  List<String> tags;

  @Index()
  DateTime date;

  DateTime createdAt;

  DateTime updatedAt;

  Expense({
    required this.amount,
    required this.categoryId,
    required this.expenseType,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.paymentMethod,
    this.tags = const <String>[],
  });
}
