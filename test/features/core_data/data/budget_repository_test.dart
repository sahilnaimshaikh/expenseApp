import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/core_data/data/budget_repository.dart';
import 'package:expense_tracker/features/core_data/domain/models/budget.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('BudgetRepository', () {
    late Isar isar;
    late BudgetRepository repository;

    setUp(() async {
      isar = await openTestIsar();
      repository = BudgetRepository(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('upsertBudget creates a new row when none exists', () async {
      final budget = Budget(month: 1, year: 2026, ledgerScope: LedgerScope.combined, budgetAmount: 20000);
      await repository.upsertBudget(budget);

      final fetched = await repository.getBudget(1, 2026, LedgerScope.combined);
      expect(fetched, isNotNull);
      expect(fetched!.budgetAmount, 20000);
    });

    test('upsertBudget updates the existing row for the same month/year/scope instead of duplicating', () async {
      await repository.upsertBudget(
        Budget(month: 2, year: 2026, ledgerScope: LedgerScope.personal, budgetAmount: 5000),
      );
      await repository.upsertBudget(
        Budget(month: 2, year: 2026, ledgerScope: LedgerScope.personal, budgetAmount: 7500),
      );

      final fetched = await repository.getBudget(2, 2026, LedgerScope.personal);
      expect(fetched!.budgetAmount, 7500);

      final history = await repository.getBudgetHistory(LedgerScope.personal);
      expect(history, hasLength(1));
    });

    test('getBudget distinguishes rows by ledgerScope for the same month/year', () async {
      await repository.upsertBudget(
        Budget(month: 3, year: 2026, ledgerScope: LedgerScope.personal, budgetAmount: 3000),
      );
      await repository.upsertBudget(
        Budget(month: 3, year: 2026, ledgerScope: LedgerScope.home, budgetAmount: 6000),
      );

      final personal = await repository.getBudget(3, 2026, LedgerScope.personal);
      final home = await repository.getBudget(3, 2026, LedgerScope.home);

      expect(personal!.budgetAmount, 3000);
      expect(home!.budgetAmount, 6000);
    });

    test('getBudget returns null when no matching row exists', () async {
      final fetched = await repository.getBudget(12, 2099, LedgerScope.combined);
      expect(fetched, isNull);
    });
  });
}
