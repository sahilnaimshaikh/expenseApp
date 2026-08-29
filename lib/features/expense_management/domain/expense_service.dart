import '../../core_data/data/category_repository.dart';
import '../../core_data/data/expense_repository.dart';
import '../../core_data/domain/models/enums.dart';
import '../../core_data/domain/models/expense.dart';
import 'expense_filter.dart';
import 'expense_input.dart';

/// Thrown when an [ExpenseInput] violates a business rule (BR-10) or a
/// filter is invalid (BR-22).
class ExpenseValidationException implements Exception {
  const ExpenseValidationException(this.message);

  final String message;

  @override
  String toString() => 'ExpenseValidationException: $message';
}

/// Business logic for expense lifecycle, search, filtering, and sorting.
///
/// See aidlc-docs/construction/onboarding-expense-management/functional-design/
/// business-rules.md (BR-10 to BR-13) and
/// aidlc-docs/construction/search-filter-reporting/functional-design/
/// business-rules.md (BR-20 to BR-23) for the rules this class implements.
class ExpenseService {
  ExpenseService(this._expenseRepository, this._categoryRepository);

  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;

  Future<Expense> addExpense(ExpenseInput input) async {
    await _validate(input);

    final now = DateTime.now();
    final expense = Expense(
      amount: input.amount,
      categoryId: input.categoryId,
      expenseType: input.expenseType,
      date: input.date ?? _today(),
      createdAt: now,
      updatedAt: now,
      description: input.description,
      paymentMethod: input.paymentMethod,
      tags: input.tags,
    );

    return _expenseRepository.create(expense);
  }

  Future<Expense> editExpense(int id, ExpenseInput input) async {
    await _validate(input);

    final existing = await _expenseRepository.getById(id);
    if (existing == null) {
      throw const ExpenseValidationException('This expense no longer exists.');
    }

    existing.amount = input.amount;
    existing.categoryId = input.categoryId;
    existing.expenseType = input.expenseType;
    existing.date = input.date ?? existing.date;
    existing.description = input.description;
    existing.paymentMethod = input.paymentMethod;
    existing.tags = input.tags;
    // BR-12: createdAt is never touched; updatedAt always refreshes.
    existing.updatedAt = DateTime.now();

    return _expenseRepository.update(existing);
  }

  Future<void> deleteExpense(int id) async {
    await _expenseRepository.delete(id);
  }

  /// BR-13: bulk delete used by the Expense List's multi-select action
  /// (stories.md US-05 AC3).
  Future<void> deleteMany(List<int> ids) async {
    for (final id in ids) {
      await _expenseRepository.delete(id);
    }
  }

  Future<List<Expense>> listExpenses({int limit = 50, int offset = 0}) async {
    return _expenseRepository.query(ExpenseQueryParams(limit: limit, offset: offset));
  }

  /// BR-20: matches [query] (case-insensitive) against description,
  /// resolved category name, tags, or payment method.
  Future<List<Expense>> searchExpenses(String query) async {
    if (query.trim().isEmpty) {
      return _expenseRepository.query(const ExpenseQueryParams(limit: 1000000));
    }

    final normalized = query.trim().toLowerCase();
    final categories = await _categoryRepository.getAll();
    final categoryNamesById = {for (final c in categories) c.id: c.name.toLowerCase()};

    final all = await _expenseRepository.query(const ExpenseQueryParams(limit: 1000000));
    return all.where((e) {
      final description = e.description?.toLowerCase() ?? '';
      final categoryName = categoryNamesById[e.categoryId] ?? '';
      final tagsMatch = e.tags.any((t) => t.toLowerCase().contains(normalized));
      final paymentMethodMatch = e.paymentMethod?.name.toLowerCase().contains(normalized) ?? false;

      return description.contains(normalized) ||
          categoryName.contains(normalized) ||
          tagsMatch ||
          paymentMethodMatch;
    }).toList();
  }

  /// BR-21 (AND-combined filters), BR-22 (amount-range validation), BR-23
  /// (stable sort tie-breaking).
  Future<List<Expense>> filterAndSort(ExpenseFilter filter, ExpenseSort sort) async {
    if (filter.minAmount != null && filter.maxAmount != null && filter.minAmount! > filter.maxAmount!) {
      throw const ExpenseValidationException('Minimum amount cannot be greater than maximum amount.');
    }

    final results = await _expenseRepository.query(ExpenseQueryParams(
      startDate: filter.startDate,
      endDate: filter.endDate,
      categoryId: filter.categoryId,
      expenseType: filter.expenseType,
      paymentMethod: filter.paymentMethod,
      minAmount: filter.minAmount,
      maxAmount: filter.maxAmount,
      limit: 1000000,
    ));

    return _sortWithStableTieBreak(results, sort);
  }

  List<Expense> _sortWithStableTieBreak(List<Expense> expenses, ExpenseSort sort) {
    final sorted = [...expenses];
    switch (sort) {
      case ExpenseSort.newestFirst:
        sorted.sort((a, b) {
          final byDate = b.date.compareTo(a.date);
          return byDate != 0 ? byDate : a.id.compareTo(b.id);
        });
      case ExpenseSort.oldestFirst:
        sorted.sort((a, b) {
          final byDate = a.date.compareTo(b.date);
          return byDate != 0 ? byDate : a.id.compareTo(b.id);
        });
      case ExpenseSort.highestAmount:
        sorted.sort((a, b) {
          final byAmount = b.amount.compareTo(a.amount);
          return byAmount != 0 ? byAmount : a.id.compareTo(b.id);
        });
      case ExpenseSort.lowestAmount:
        sorted.sort((a, b) {
          final byAmount = a.amount.compareTo(b.amount);
          return byAmount != 0 ? byAmount : a.id.compareTo(b.id);
        });
    }
    return sorted;
  }

  Future<void> _validate(ExpenseInput input) async {
    if (input.amount <= 0) {
      throw const ExpenseValidationException('Amount must be greater than zero.');
    }

    final categories = await _categoryRepository.getAll();
    final categoryExists = categories.any((c) => c.id == input.categoryId);
    if (!categoryExists) {
      throw const ExpenseValidationException('Please select a valid category.');
    }
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
