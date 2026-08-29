import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, setUp, tearDown, setUpAll, tearDownAll, expect;
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/core_data/data/budget_repository.dart';
import 'package:expense_tracker/features/core_data/data/category_repository.dart';
import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/domain/budget_service.dart';
import 'package:expense_tracker/features/core_data/domain/models/category.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/core_data/domain/models/expense.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('BudgetService (Unit 3: recalculate/evaluateThresholds)', () {
    late Isar isar;
    late BudgetService service;
    late ExpenseRepository expenseRepository;
    late int categoryId;
    const month = 6;
    const year = 2026;

    setUp(() async {
      isar = await openTestIsar();
      final budgetRepository = BudgetRepository(isar);
      expenseRepository = ExpenseRepository(isar);
      service = BudgetService(budgetRepository, expenseRepository);

      final category = await CategoryRepository(isar).create(
        Category(name: 'Food', icon: 'x', color: '#000', isDefault: true),
      );
      categoryId = category.id;
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    Future<void> addExpense(double amount, ExpenseType type) async {
      await expenseRepository.create(Expense(
        amount: amount,
        categoryId: categoryId,
        expenseType: type,
        date: DateTime(year, month, 15),
        createdAt: DateTime(year, month, 15),
        updatedAt: DateTime(year, month, 15),
      ));
    }

    // BR-17: divide-by-zero guard.
    test('recalculate returns 0% and hasBudgetConfigured=false when no budget exists', () async {
      final status = await service.recalculate(month, year, LedgerScope.combined);
      expect(status.hasBudgetConfigured, isFalse);
      expect(status.percentageUsed, 0);
    });

    test('recalculate computes correct spend, remaining, and percentage', () async {
      await service.setBudgetAmount(month: month, year: year, scope: LedgerScope.combined, amount: 1000);
      await addExpense(300, ExpenseType.personal);
      await addExpense(200, ExpenseType.home);

      final status = await service.recalculate(month, year, LedgerScope.combined);
      expect(status.amountSpent, 500);
      expect(status.remainingAmount, 500);
      expect(status.percentageUsed, 50);
    });

    // BR-19: combined vs per-ledger attribution.
    test('combined scope sums personal + home; personal/home scopes are exclusive', () async {
      await addExpense(300, ExpenseType.personal);
      await addExpense(200, ExpenseType.home);

      final combined = await service.recalculate(month, year, LedgerScope.combined);
      final personal = await service.recalculate(month, year, LedgerScope.personal);
      final home = await service.recalculate(month, year, LedgerScope.home);

      expect(combined.amountSpent, 500);
      expect(personal.amountSpent, 300);
      expect(home.amountSpent, 200);
    });

    // BR-14: fires at most once per month per threshold.
    test('evaluateThresholds fires each threshold only once even across repeated crossings', () async {
      await service.setBudgetAmount(month: month, year: year, scope: LedgerScope.combined, amount: 1000);

      await addExpense(600, ExpenseType.personal); // 60% -> crosses 50
      var crossings = await service.evaluateThresholds(month, year, LedgerScope.combined);
      expect(crossings.map((c) => c.threshold), [50]);

      // Re-evaluate without any new expense: no new crossings.
      crossings = await service.evaluateThresholds(month, year, LedgerScope.combined);
      expect(crossings, isEmpty);

      await addExpense(200, ExpenseType.personal); // 80% -> crosses 75
      crossings = await service.evaluateThresholds(month, year, LedgerScope.combined);
      expect(crossings.map((c) => c.threshold), [75]);

      // Re-evaluating again still yields nothing for 50 or 75.
      crossings = await service.evaluateThresholds(month, year, LedgerScope.combined);
      expect(crossings, isEmpty);
    });

    // BR-15: disabled thresholds never fire.
    test('evaluateThresholds skips disabled thresholds', () async {
      await service.setBudgetAmount(month: month, year: year, scope: LedgerScope.combined, amount: 1000);
      await service.updateNotificationThresholds(
        month: month,
        year: year,
        scope: LedgerScope.combined,
        thresholdFlags: {50: false},
      );
      await addExpense(600, ExpenseType.personal);

      final crossings = await service.evaluateThresholds(month, year, LedgerScope.combined);
      expect(crossings, isEmpty);
    });

    test('evaluateThresholds returns empty when no budget configured', () async {
      final crossings = await service.evaluateThresholds(month, year, LedgerScope.combined);
      expect(crossings, isEmpty);
    });

    // PBT: percentage invariant across generated amounts.
    Glados2(any.doubleInRange(1, 100000), any.doubleInRange(1, 100000)).test(
      'invariant: percentageUsed == (spent / budget) * 100 within tolerance',
      (budgetAmount, expenseAmount) async {
        final freshIsar = await openTestIsar();
        try {
          final freshExpenseRepo = ExpenseRepository(freshIsar);
          final freshService = BudgetService(BudgetRepository(freshIsar), freshExpenseRepo);
          final freshCategory = await CategoryRepository(freshIsar).create(
            Category(name: 'X', icon: 'x', color: '#000', isDefault: true),
          );

          await freshService.setBudgetAmount(month: 1, year: 2027, scope: LedgerScope.combined, amount: budgetAmount);
          await freshExpenseRepo.create(Expense(
            amount: expenseAmount,
            categoryId: freshCategory.id,
            expenseType: ExpenseType.personal,
            date: DateTime(2027, 1, 10),
            createdAt: DateTime(2027, 1, 10),
            updatedAt: DateTime(2027, 1, 10),
          ));

          final status = await freshService.recalculate(1, 2027, LedgerScope.combined);
          final expectedPercentage = (expenseAmount / budgetAmount) * 100;

          expect(status.percentageUsed, closeTo(expectedPercentage, 0.01));
        } finally {
          await freshIsar.close(deleteFromDisk: true);
        }
      },
    );
  });
}
