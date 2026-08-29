import '../../core_data/domain/models/enums.dart';

/// Transient filter criteria for [ExpenseService.filterAndSort] (US-08).
/// All fields optional and AND-combined (BR-21).
class ExpenseFilter {
  const ExpenseFilter({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.expenseType,
    this.paymentMethod,
    this.minAmount,
    this.maxAmount,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final ExpenseType? expenseType;
  final PaymentMethod? paymentMethod;
  final double? minAmount;
  final double? maxAmount;
}

/// Sort order for [ExpenseService.filterAndSort] (US-09). Ties broken per
/// BR-23.
enum ExpenseSort {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount,
}
