import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, setUp, tearDown, setUpAll, tearDownAll, expect;
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/core_data/data/category_repository.dart';
import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/domain/models/category.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/core_data/domain/models/expense.dart';
import 'package:expense_tracker/features/expense_management/domain/expense_filter.dart';
import 'package:expense_tracker/features/expense_management/domain/expense_service.dart';

import '../../../helpers/isar_test_helper.dart';

Expense _expense({
  required double amount,
  required int categoryId,
  ExpenseType type = ExpenseType.personal,
  String? description,
  List<String> tags = const [],
  DateTime? date,
}) {
  final d = date ?? DateTime(2026, 3, 15);
  return Expense(
    amount: amount,
    categoryId: categoryId,
    expenseType: type,
    date: d,
    createdAt: d,
    updatedAt: d,
    description: description,
    tags: tags,
  );
}

void main() {
  group('ExpenseService.searchExpenses (BR-20)', () {
    late Isar isar;
    late ExpenseRepository expenseRepository;
    late ExpenseService service;
    late int categoryId;

    setUp(() async {
      isar = await openTestIsar();
      final categoryRepository = CategoryRepository(isar);
      expenseRepository = ExpenseRepository(isar);
      service = ExpenseService(expenseRepository, categoryRepository);
      final category = await categoryRepository.create(
        Category(name: 'Groceries', icon: 'x', color: '#000', isDefault: true),
      );
      categoryId = category.id;
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('matches by description (case-insensitive)', () async {
      final categoryRepository = CategoryRepository(isar);
      final otherCategory = await categoryRepository.create(
        Category(name: 'Entertainment', icon: 'x', color: '#000', isDefault: true),
      );

      await expenseRepository.create(_expense(amount: 10, categoryId: categoryId, description: 'Weekly Groceries'));
      await expenseRepository.create(
        _expense(amount: 20, categoryId: otherCategory.id, description: 'Movie ticket'),
      );

      final results = await service.searchExpenses('groceries');
      expect(results, hasLength(1));
      expect(results.single.description, 'Weekly Groceries');
    });

    test('matches by category name', () async {
      await expenseRepository.create(_expense(amount: 10, categoryId: categoryId));
      final results = await service.searchExpenses('grocer');
      expect(results, hasLength(1));
    });

    test('matches by tag', () async {
      await expenseRepository.create(_expense(amount: 10, categoryId: categoryId, tags: ['urgent', 'family']));
      final results = await service.searchExpenses('family');
      expect(results, hasLength(1));
    });

    test('empty query returns all expenses', () async {
      await expenseRepository.create(_expense(amount: 10, categoryId: categoryId));
      await expenseRepository.create(_expense(amount: 20, categoryId: categoryId));
      final results = await service.searchExpenses('');
      expect(results, hasLength(2));
    });
  });

  group('ExpenseService.filterAndSort (BR-21, BR-22, BR-23)', () {
    late Isar isar;
    late ExpenseRepository expenseRepository;
    late ExpenseService service;
    late int categoryId;

    setUp(() async {
      isar = await openTestIsar();
      final categoryRepository = CategoryRepository(isar);
      expenseRepository = ExpenseRepository(isar);
      service = ExpenseService(expenseRepository, categoryRepository);
      final category = await categoryRepository.create(
        Category(name: 'X', icon: 'x', color: '#000', isDefault: true),
      );
      categoryId = category.id;
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('rejects minAmount > maxAmount', () async {
      expect(
        () => service.filterAndSort(
          const ExpenseFilter(minAmount: 100, maxAmount: 50),
          ExpenseSort.newestFirst,
        ),
        throwsA(isA<ExpenseValidationException>()),
      );
    });

    test('AND-combines multiple filter fields', () async {
      await expenseRepository.create(_expense(amount: 50, categoryId: categoryId, type: ExpenseType.personal));
      await expenseRepository.create(_expense(amount: 50, categoryId: categoryId, type: ExpenseType.home));
      await expenseRepository.create(_expense(amount: 999, categoryId: categoryId, type: ExpenseType.personal));

      final results = await service.filterAndSort(
        ExpenseFilter(expenseType: ExpenseType.personal, minAmount: 10, maxAmount: 100),
        ExpenseSort.newestFirst,
      );

      expect(results, hasLength(1));
      expect(results.single.amount, 50);
      expect(results.single.expenseType, ExpenseType.personal);
    });

    test('sorts highestAmount descending with stable id tie-break', () async {
      final e1 = await expenseRepository.create(_expense(amount: 100, categoryId: categoryId));
      final e2 = await expenseRepository.create(_expense(amount: 100, categoryId: categoryId));
      final e3 = await expenseRepository.create(_expense(amount: 200, categoryId: categoryId));

      final results = await service.filterAndSort(const ExpenseFilter(), ExpenseSort.highestAmount);

      expect(results.map((e) => e.id), [e3.id, e1.id, e2.id]);
    });

    test('sorts lowestAmount ascending', () async {
      await expenseRepository.create(_expense(amount: 200, categoryId: categoryId));
      await expenseRepository.create(_expense(amount: 50, categoryId: categoryId));

      final results = await service.filterAndSort(const ExpenseFilter(), ExpenseSort.lowestAmount);
      expect(results.first.amount, 50);
      expect(results.last.amount, 200);
    });

    // PBT: filter AND-combination invariant.
    Glados2(any.doubleInRange(1, 1000), any.choose([ExpenseType.personal, ExpenseType.home])).test(
      'invariant: every result satisfies every set filter field',
      (amount, type) async {
        final freshIsar = await openTestIsar();
        try {
          final freshCategoryRepo = CategoryRepository(freshIsar);
          final freshExpenseRepo = ExpenseRepository(freshIsar);
          final freshService = ExpenseService(freshExpenseRepo, freshCategoryRepo);
          final freshCategory = await freshCategoryRepo.create(
            Category(name: 'Y', icon: 'x', color: '#000', isDefault: true),
          );

          await freshExpenseRepo.create(_expense(amount: amount, categoryId: freshCategory.id, type: type));
          await freshExpenseRepo.create(_expense(amount: amount + 1000, categoryId: freshCategory.id, type: type));

          final results = await freshService.filterAndSort(
            ExpenseFilter(expenseType: type, maxAmount: amount + 500),
            ExpenseSort.newestFirst,
          );

          for (final r in results) {
            expect(r.expenseType, type);
            expect(r.amount, lessThanOrEqualTo(amount + 500));
          }
        } finally {
          await freshIsar.close(deleteFromDisk: true);
        }
      },
    );
  });
}
