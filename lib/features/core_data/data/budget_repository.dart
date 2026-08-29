import 'package:isar/isar.dart';

import '../domain/models/budget.dart';
import '../domain/models/enums.dart';
import '../domain/repository_exception.dart';

/// Thin CRUD repository over the Isar `Budget` collection.
///
/// Full budget business logic (recalculation, threshold evaluation) is
/// owned by BudgetService in Unit 3 — this repository exposes only the
/// storage-level operations that unit needs, per component-methods.md.
class BudgetRepository {
  BudgetRepository(this._isar);

  final Isar _isar;

  Future<Budget?> getBudget(int month, int year, LedgerScope scope) async {
    try {
      return await _isar.budgets
          .filter()
          .monthEqualTo(month)
          .yearEqualTo(year)
          .ledgerScopeEqualTo(scope)
          .findFirst();
    } catch (e) {
      throw RepositoryException(
        operation: 'Budget.getBudget',
        message: "Couldn't load your budget. Please try again.",
        cause: e,
      );
    }
  }

  /// Creates the budget row for (month, year, scope) if none exists, or
  /// updates the existing row's amount/notification flags otherwise.
  Future<Budget> upsertBudget(Budget budget) async {
    try {
      final existing = await getBudget(budget.month, budget.year, budget.ledgerScope);
      if (existing != null) {
        budget.id = existing.id;
      }
      await _isar.writeTxn(() async {
        await _isar.budgets.put(budget);
      });
      return budget;
    } catch (e) {
      throw RepositoryException(
        operation: 'Budget.upsertBudget',
        message: "Couldn't save your budget. Please try again.",
        cause: e,
      );
    }
  }

  Future<List<Budget>> getBudgetHistory(LedgerScope scope) async {
    try {
      return await _isar.budgets
          .filter()
          .ledgerScopeEqualTo(scope)
          .sortByYearDesc()
          .thenByMonthDesc()
          .findAll();
    } catch (e) {
      throw RepositoryException(
        operation: 'Budget.getBudgetHistory',
        message: "Couldn't load your budget history. Please try again.",
        cause: e,
      );
    }
  }

  /// All budget rows across every scope/month/year — needed by
  /// [BackupService] for full-dataset backup (Unit 6). Not used by
  /// business-logic services, which always query a specific
  /// month/year/scope.
  Future<List<Budget>> getAll() async {
    try {
      return await _isar.budgets.where().findAll();
    } catch (e) {
      throw RepositoryException(
        operation: 'Budget.getAll',
        message: "Couldn't load your budgets. Please try again.",
        cause: e,
      );
    }
  }

  /// Replaces every Budget row with [budgets] inside a single transaction
  /// — used only by [BackupService.restoreFromBackup] (BR-29's
  /// validate-before-mutate restore, applied here as clear-then-reload).
  Future<void> replaceAll(List<Budget> budgets) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.budgets.clear();
        await _isar.budgets.putAll(budgets);
      });
    } catch (e) {
      throw RepositoryException(
        operation: 'Budget.replaceAll',
        message: "Couldn't restore your budgets. Please try again.",
        cause: e,
      );
    }
  }
}
