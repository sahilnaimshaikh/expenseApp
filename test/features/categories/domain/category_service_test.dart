import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, setUp, tearDown, setUpAll, tearDownAll, expect, expectLater;
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/categories/domain/category_service.dart';
import 'package:expense_tracker/features/core_data/data/category_repository.dart';
import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/domain/models/category.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/core_data/domain/models/expense.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('CategoryService', () {
    late Isar isar;
    late CategoryRepository categoryRepository;
    late ExpenseRepository expenseRepository;
    late CategoryService service;

    setUp(() async {
      isar = await openTestIsar();
      categoryRepository = CategoryRepository(isar);
      expenseRepository = ExpenseRepository(isar);
      service = CategoryService(categoryRepository, expenseRepository);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('ensureDefaultsSeeded inserts all 13 PRD default categories', () async {
      await service.ensureDefaultsSeeded();
      final all = await categoryRepository.getAll();

      expect(all, hasLength(DefaultCategories.all.length));
      expect(all.every((c) => c.isDefault), isTrue);
    });

    // BR-4 idempotence property.
    test('ensureDefaultsSeeded is idempotent across repeated calls', () async {
      await service.ensureDefaultsSeeded();
      await service.ensureDefaultsSeeded();
      await service.ensureDefaultsSeeded();

      final all = await categoryRepository.getAll();
      expect(all, hasLength(DefaultCategories.all.length));
    });

    // BR-1 uniqueness (case-insensitive).
    test('createCustomCategory rejects a case-insensitive duplicate name', () async {
      await service.createCustomCategory(name: 'Pets', icon: 'pets', color: '#000000');

      expect(
        () => service.createCustomCategory(name: 'pets', icon: 'pets', color: '#111111'),
        throwsA(isA<CategoryValidationException>()),
      );
    });

    test('createCustomCategory succeeds for a unique name', () async {
      final created = await service.createCustomCategory(
        name: 'Subscriptions',
        icon: 'subscriptions',
        color: '#123456',
      );

      expect(created.isDefault, isFalse);
      expect(created.name, 'Subscriptions');
    });

    // BR-2 default protection.
    test('deleteCategory rejects deletion of a default category', () async {
      await service.ensureDefaultsSeeded();
      final all = await categoryRepository.getAll();
      final food = all.firstWhere((c) => c.name == 'Food');

      expect(
        () => service.deleteCategory(food.id),
        throwsA(isA<CategoryValidationException>()),
      );
    });

    // BR-3 reassignment on delete.
    test('deleteCategory reassigns affected expenses to Others then deletes the category', () async {
      await service.ensureDefaultsSeeded();
      final custom = await service.createCustomCategory(name: 'Hobby', icon: 'star', color: '#abcdef');

      final expense = await expenseRepository.create(Expense(
        amount: 42,
        categoryId: custom.id,
        expenseType: ExpenseType.personal,
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

      await service.deleteCategory(custom.id);

      final others = (await categoryRepository.getAll()).firstWhere((c) => c.name == 'Others');
      final refreshed = await expenseRepository.getById(expense.id);

      expect(refreshed!.categoryId, others.id);

      final categories = await categoryRepository.getAll();
      expect(categories.any((c) => c.id == custom.id), isFalse);
    });

    test('deleteCategory on a custom category with no expenses just deletes it', () async {
      final custom = await service.createCustomCategory(name: 'Unused', icon: 'star', color: '#abcdef');
      await service.deleteCategory(custom.id);

      final categories = await categoryRepository.getAll();
      expect(categories.any((c) => c.id == custom.id), isFalse);
    });

    // PBT-03 invariant: name uniqueness holds across any sequence of
    // create operations with generated names.
    Glados(any.letterOrDigits.map((s) => s.isEmpty ? 'x' : s)).test(
      'invariant: after creating a category, no duplicate of its name can be created',
      (name) async {
        // Fresh isar per property-run to keep each generated case independent.
        final freshIsar = await openTestIsar();
        try {
          final freshService = CategoryService(
            CategoryRepository(freshIsar),
            ExpenseRepository(freshIsar),
          );

          await freshService.createCustomCategory(name: name, icon: 'x', color: '#000000');

          await expectLater(
            freshService.createCustomCategory(name: name.toUpperCase(), icon: 'x', color: '#000000'),
            throwsA(isA<CategoryValidationException>()),
          );
        } finally {
          await freshIsar.close(deleteFromDisk: true);
        }
      },
    );
  });
}
