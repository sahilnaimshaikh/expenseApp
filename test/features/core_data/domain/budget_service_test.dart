import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/core_data/data/budget_repository.dart';
import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/domain/budget_service.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('BudgetService.setBudgetAmount (Unit 1 slice)', () {
    late Isar isar;
    late BudgetService service;

    setUp(() async {
      isar = await openTestIsar();
      service = BudgetService(BudgetRepository(isar), ExpenseRepository(isar));
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('creates a budget when none exists for the month/year/scope', () async {
      await service.setBudgetAmount(month: 1, year: 2026, scope: LedgerScope.combined, amount: 25000);

      final repo = BudgetRepository(isar);
      final budget = await repo.getBudget(1, 2026, LedgerScope.combined);
      expect(budget!.budgetAmount, 25000);
    });

    test('updates the existing budget rather than creating a duplicate', () async {
      await service.setBudgetAmount(month: 2, year: 2026, scope: LedgerScope.personal, amount: 5000);
      await service.setBudgetAmount(month: 2, year: 2026, scope: LedgerScope.personal, amount: 8000);

      final repo = BudgetRepository(isar);
      final history = await repo.getBudgetHistory(LedgerScope.personal);
      expect(history, hasLength(1));
      expect(history.single.budgetAmount, 8000);
    });

    // BR-7 positivity rule.
    test('rejects a zero or negative amount', () async {
      expect(
        () => service.setBudgetAmount(month: 3, year: 2026, scope: LedgerScope.combined, amount: 0),
        throwsA(isA<BudgetValidationException>()),
      );
      expect(
        () => service.setBudgetAmount(month: 3, year: 2026, scope: LedgerScope.combined, amount: -100),
        throwsA(isA<BudgetValidationException>()),
      );
    });
  });
}
