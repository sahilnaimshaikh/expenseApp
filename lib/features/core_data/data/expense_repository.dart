import 'package:isar/isar.dart';

import '../domain/models/enums.dart';
import '../domain/models/expense.dart';
import '../domain/repository_exception.dart';

/// Basic filter/sort parameters for [ExpenseRepository.query].
///
/// This is intentionally a thin, mechanical filter — all aggregation and
/// business-rule-driven querying (search, combined filter+sort, budget
/// summation) lives in later units' services, per the Application Design
/// Q3 decision (repositories stay thin).
class ExpenseQueryParams {
  const ExpenseQueryParams({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.expenseType,
    this.paymentMethod,
    this.minAmount,
    this.maxAmount,
    this.limit,
    this.offset,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final ExpenseType? expenseType;
  final PaymentMethod? paymentMethod;
  final double? minAmount;
  final double? maxAmount;

  /// Supports lazy pagination for large datasets (NFR-2, 500,000+ records).
  final int? limit;
  final int? offset;
}

/// Thin CRUD + basic query repository over the Isar `Expense` collection.
///
/// See component-methods.md for the method contract this class implements.
class ExpenseRepository {
  ExpenseRepository(this._isar);

  final Isar _isar;

  Future<Expense> create(Expense expense) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.expenses.put(expense);
      });
      return expense;
    } catch (e) {
      throw RepositoryException(
        operation: 'Expense.create',
        message: "Couldn't save your expense. Please try again.",
        cause: e,
      );
    }
  }

  Future<Expense> update(Expense expense) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.expenses.put(expense);
      });
      return expense;
    } catch (e) {
      throw RepositoryException(
        operation: 'Expense.update',
        message: "Couldn't update your expense. Please try again.",
        cause: e,
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.expenses.delete(id);
      });
    } catch (e) {
      throw RepositoryException(
        operation: 'Expense.delete',
        message: "Couldn't delete this expense. Please try again.",
        cause: e,
      );
    }
  }

  Future<Expense?> getById(int id) async {
    try {
      return await _isar.expenses.get(id);
    } catch (e) {
      throw RepositoryException(
        operation: 'Expense.getById',
        message: "Couldn't load this expense. Please try again.",
        cause: e,
      );
    }
  }

  Future<List<Expense>> query(ExpenseQueryParams params) async {
    try {
      // Isar's `.optional()` extension applies a filter step only when its
      // condition is true, letting each ExpenseQueryParams field stay
      // independently optional without brittle QueryBuilder-type casting.
      final result = _isar.expenses
          .filter()
          .optional(params.startDate != null, (q) => q.dateGreaterThan(params.startDate!, include: true))
          .optional(params.endDate != null, (q) => q.dateLessThan(params.endDate!, include: true))
          .optional(params.categoryId != null, (q) => q.categoryIdEqualTo(params.categoryId!))
          .optional(params.expenseType != null, (q) => q.expenseTypeEqualTo(params.expenseType!))
          .optional(params.paymentMethod != null, (q) => q.paymentMethodEqualTo(params.paymentMethod!))
          .optional(params.minAmount != null, (q) => q.amountGreaterThan(params.minAmount!, include: true))
          .optional(params.maxAmount != null, (q) => q.amountLessThan(params.maxAmount!, include: true))
          .sortByDateDesc()
          .optional(params.offset != null, (q) => q.offset(params.offset!))
          .optional(params.limit != null, (q) => q.limit(params.limit!));

      return await result.findAll();
    } catch (e) {
      throw RepositoryException(
        operation: 'Expense.query',
        message: "Couldn't load your expenses. Please try again.",
        cause: e,
      );
    }
  }

  /// Reactive stream of all expenses, sorted by date descending (newest
  /// first), for dashboard/list UIs that should update automatically when
  /// data changes (nfr-design-patterns.md "Streaming reads pattern").
  Stream<List<Expense>> watchAll() {
    return _isar.expenses.where().sortByDateDesc().watch(fireImmediately: true);
  }

  /// All expense rows, unfiltered — needed by [BackupService]/[ExportService]
  /// for full-dataset backup/export (Unit 6, BR-30: export always covers
  /// all data by default).
  Future<List<Expense>> getAll() async {
    try {
      return await _isar.expenses.where().findAll();
    } catch (e) {
      throw RepositoryException(
        operation: 'Expense.getAll',
        message: "Couldn't load your expenses. Please try again.",
        cause: e,
      );
    }
  }

  /// Replaces every Expense row with [expenses] inside a single
  /// transaction — used only by [BackupService.restoreFromBackup].
  Future<void> replaceAll(List<Expense> expenses) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.expenses.clear();
        await _isar.expenses.putAll(expenses);
      });
    } catch (e) {
      throw RepositoryException(
        operation: 'Expense.replaceAll',
        message: "Couldn't restore your expenses. Please try again.",
        cause: e,
      );
    }
  }
}
