import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/core_data/data/budget_repository.dart';
import 'package:expense_tracker/features/core_data/data/category_repository.dart';
import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/domain/budget_service.dart';
import 'package:expense_tracker/features/core_data/domain/models/category.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/core_data/domain/models/expense.dart';
import 'package:expense_tracker/features/reporting/domain/report_service.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('ReportService', () {
    late Isar isar;
    late ExpenseRepository expenseRepository;
    late CategoryRepository categoryRepository;
    late ReportService service;
    late int foodId;
    late int travelId;
    const month = 4;
    const year = 2026;

    setUp(() async {
      isar = await openTestIsar();
      expenseRepository = ExpenseRepository(isar);
      categoryRepository = CategoryRepository(isar);
      final budgetService = BudgetService(BudgetRepository(isar), expenseRepository);
      service = ReportService(expenseRepository, categoryRepository, budgetService);

      foodId = (await categoryRepository.create(Category(name: 'Food', icon: 'x', color: '#000', isDefault: true))).id;
      travelId = (await categoryRepository.create(Category(name: 'Travel', icon: 'x', color: '#000', isDefault: true))).id;
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    Future<void> addExpense(double amount, int categoryId, {ExpenseType type = ExpenseType.personal, int day = 15}) async {
      await expenseRepository.create(Expense(
        amount: amount,
        categoryId: categoryId,
        expenseType: type,
        date: DateTime(year, month, day),
        createdAt: DateTime(year, month, day),
        updatedAt: DateTime(year, month, day),
      ));
    }

    // BR-24: zero-value categories included.
    test('categoryAnalysis includes categories with zero spend', () async {
      await addExpense(100, foodId);
      final results = await service.categoryAnalysis(month, year);

      final travel = results.firstWhere((c) => c.categoryId == travelId);
      expect(travel.total, 0);
      final food = results.firstWhere((c) => c.categoryId == foodId);
      expect(food.total, 100);
    });

    // PBT-style invariant, tested as an example: category totals sum to the combined total.
    test('categoryAnalysis totals sum to the combined monthlySpending total', () async {
      final now = DateTime.now();

      Future<void> addCurrentMonthExpense(double amount, int categoryId) => expenseRepository.create(Expense(
            amount: amount,
            categoryId: categoryId,
            expenseType: ExpenseType.personal,
            date: DateTime(now.year, now.month, 1),
            createdAt: DateTime(now.year, now.month, 1),
            updatedAt: DateTime(now.year, now.month, 1),
          ));

      await addCurrentMonthExpense(100, foodId);
      await addCurrentMonthExpense(50, travelId);

      final categoryTotals = await service.categoryAnalysis(now.month, now.year);
      final sumOfCategories = categoryTotals.fold<double>(0, (acc, c) => acc + c.total);

      final monthly = await service.monthlySpending(1);
      expect(sumOfCategories, monthly.single.total);
    });

    // Personal + Home = Combined invariant.
    test('personalVsHome totals sum to the combined monthly total', () async {
      final now = DateTime.now();

      Future<void> addCurrentMonthExpense(double amount, int categoryId, ExpenseType type) =>
          expenseRepository.create(Expense(
            amount: amount,
            categoryId: categoryId,
            expenseType: type,
            date: DateTime(now.year, now.month, 1),
            createdAt: DateTime(now.year, now.month, 1),
            updatedAt: DateTime(now.year, now.month, 1),
          ));

      await addCurrentMonthExpense(100, foodId, ExpenseType.personal);
      await addCurrentMonthExpense(60, foodId, ExpenseType.home);

      final comparison = await service.personalVsHome(now.month, now.year);
      final monthly = await service.monthlySpending(1);

      expect(comparison.personalTotal + comparison.homeTotal, monthly.single.total);
    });

    test('topCategories ranks descending with stable tie-break', () async {
      await addExpense(50, foodId);
      await addExpense(50, travelId);

      final top = await service.topCategories(month, year, limit: 2);
      expect(top.first.total, 50);
      expect(top.first.categoryId, foodId < travelId ? foodId : travelId);
    });

    test('monthlyComparison returns current + prior months', () async {
      await addExpense(100, foodId);
      final result = await service.monthlyComparison(month, year, monthsBack: 2);

      expect(result.currentMonthTotal, 100);
      expect(result.priorMonths, hasLength(2));
    });

    // BR-26: budgetUtilization delegates to BudgetService, no reimplemented math.
    test('budgetUtilization matches BudgetService.getBudgetStatus percentage', () async {
      final budgetService = BudgetService(BudgetRepository(isar), expenseRepository);
      await budgetService.setBudgetAmount(month: month, year: year, scope: LedgerScope.combined, amount: 200);
      await addExpense(100, foodId);

      final utilization = await service.budgetUtilization(month, year);
      final status = await budgetService.getBudgetStatus(month, year, LedgerScope.combined);

      expect(utilization, status.percentageUsed);
    });
  });
}
