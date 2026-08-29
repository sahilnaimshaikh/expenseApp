import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, setUp, tearDown, setUpAll, tearDownAll, expect, expectLater;
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/core_data/data/category_repository.dart';
import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/domain/models/category.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/expense_management/domain/expense_input.dart';
import 'package:expense_tracker/features/expense_management/domain/expense_service.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('ExpenseService', () {
    late Isar isar;
    late ExpenseRepository expenseRepository;
    late CategoryRepository categoryRepository;
    late ExpenseService service;
    late int validCategoryId;

    setUp(() async {
      isar = await openTestIsar();
      expenseRepository = ExpenseRepository(isar);
      categoryRepository = CategoryRepository(isar);
      service = ExpenseService(expenseRepository, categoryRepository);

      final category = await categoryRepository.create(
        Category(name: 'Food', icon: 'restaurant', color: '#000', isDefault: true),
      );
      validCategoryId = category.id;
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('addExpense persists with defaulted date when none supplied', () async {
      final created = await service.addExpense(ExpenseInput(
        amount: 100,
        categoryId: validCategoryId,
        expenseType: ExpenseType.personal,
      ));

      final now = DateTime.now();
      expect(created.date.year, now.year);
      expect(created.date.month, now.month);
      expect(created.date.day, now.day);
    });

    // BR-10 validation.
    test('addExpense rejects amount <= 0', () async {
      expect(
        () => service.addExpense(ExpenseInput(
          amount: 0,
          categoryId: validCategoryId,
          expenseType: ExpenseType.personal,
        )),
        throwsA(isA<ExpenseValidationException>()),
      );
    });

    test('addExpense rejects an unknown categoryId', () async {
      expect(
        () => service.addExpense(ExpenseInput(
          amount: 10,
          categoryId: 999999,
          expenseType: ExpenseType.personal,
        )),
        throwsA(isA<ExpenseValidationException>()),
      );
    });

    // BR-12: edit preserves createdAt, refreshes updatedAt.
    test('editExpense preserves createdAt and refreshes updatedAt', () async {
      final created = await service.addExpense(ExpenseInput(
        amount: 50,
        categoryId: validCategoryId,
        expenseType: ExpenseType.personal,
      ));
      final originalCreatedAt = created.createdAt;

      await Future<void>.delayed(const Duration(milliseconds: 5));

      final edited = await service.editExpense(created.id, ExpenseInput(
        amount: 75,
        categoryId: validCategoryId,
        expenseType: ExpenseType.home,
      ));

      expect(edited.createdAt, originalCreatedAt);
      expect(edited.updatedAt.isAfter(originalCreatedAt) || edited.updatedAt == originalCreatedAt, isTrue);
      expect(edited.amount, 75);
      expect(edited.expenseType, ExpenseType.home);
    });

    // BR-13: bulk delete is all-or-nothing (transactional).
    test('deleteMany removes all specified expenses', () async {
      final e1 = await service.addExpense(ExpenseInput(amount: 10, categoryId: validCategoryId, expenseType: ExpenseType.personal));
      final e2 = await service.addExpense(ExpenseInput(amount: 20, categoryId: validCategoryId, expenseType: ExpenseType.personal));

      await service.deleteMany([e1.id, e2.id]);

      expect(await expenseRepository.getById(e1.id), isNull);
      expect(await expenseRepository.getById(e2.id), isNull);
    });

    // PBT property: amount positivity invariant.
    Glados(any.double).test(
      'invariant: addExpense succeeds iff amount > 0 (for a valid category)',
      (amount) async {
        if (amount > 0) {
          final created = await service.addExpense(ExpenseInput(
            amount: amount,
            categoryId: validCategoryId,
            expenseType: ExpenseType.personal,
          ));
          expect(created.amount, amount);
        } else {
          await expectLater(
            service.addExpense(ExpenseInput(
              amount: amount,
              categoryId: validCategoryId,
              expenseType: ExpenseType.personal,
            )),
            throwsA(isA<ExpenseValidationException>()),
          );
        }
      },
    );
  });
}
