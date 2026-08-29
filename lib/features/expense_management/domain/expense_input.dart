import '../../core_data/domain/models/enums.dart';

/// Transient DTO carrying user input from the Add/Edit Expense UI into
/// [ExpenseService]. Never persisted directly — [ExpenseService] converts
/// this into an [Expense] entity (see business-logic-model.md Process 2/3).
class ExpenseInput {
  const ExpenseInput({
    required this.amount,
    required this.categoryId,
    required this.expenseType,
    this.date,
    this.description,
    this.paymentMethod,
    this.tags = const [],
  });

  final double amount;
  final int categoryId;
  final ExpenseType expenseType;

  /// If null, [ExpenseService] defaults this to "today" (BR-11).
  final DateTime? date;

  final String? description;
  final PaymentMethod? paymentMethod;
  final List<String> tags;
}
