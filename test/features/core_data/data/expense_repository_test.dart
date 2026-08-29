import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, setUp, tearDown, setUpAll, tearDownAll, expect;
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/core_data/domain/models/expense.dart';

import '../../../helpers/isar_test_helper.dart';

/// A domain-appropriate generator for [Expense], per PBT-07 (generator
/// quality) — constrained to realistic amounts and valid enum values,
/// not raw unconstrained primitives.
Generator<Expense> get anyExpense => any.combine6(
      any.doubleInRange(0.01, 999999.99),
      any.intInRange(1, 1000),
      any.choose([ExpenseType.personal, ExpenseType.home]),
      any.letterOrDigits.map((s) => s.isEmpty ? null : s),
      any.listWithLengthInRange(0, 4, any.letterOrDigits),
      any.intInRange(-3650, 0), // days offset from "now", up to ~10 years back
      (double amount, int categoryId, ExpenseType type, String? description, List<String> tags, int daysAgo) {
        final now = DateTime(2026, 1, 1); // fixed reference to keep generation deterministic
        return Expense(
          amount: amount,
          categoryId: categoryId,
          expenseType: type,
          date: now.subtract(Duration(days: -daysAgo)),
          createdAt: now,
          updatedAt: now,
          description: description,
          tags: tags,
        );
      },
    );

void main() {
  group('ExpenseRepository', () {
    late Isar isar;
    late ExpenseRepository repository;

    setUp(() async {
      isar = await openTestIsar();
      repository = ExpenseRepository(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('create then getById returns the persisted expense', () async {
      final expense = Expense(
        amount: 150.50,
        categoryId: 1,
        expenseType: ExpenseType.personal,
        date: DateTime(2026, 1, 15),
        createdAt: DateTime(2026, 1, 15),
        updatedAt: DateTime(2026, 1, 15),
        description: 'Lunch',
      );

      final created = await repository.create(expense);
      final fetched = await repository.getById(created.id);

      expect(fetched, isNotNull);
      expect(fetched!.amount, 150.50);
      expect(fetched.description, 'Lunch');
      expect(fetched.expenseType, ExpenseType.personal);
    });

    test('update persists changes and getById reflects them', () async {
      final created = await repository.create(Expense(
        amount: 100,
        categoryId: 1,
        expenseType: ExpenseType.personal,
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

      created.amount = 200;
      await repository.update(created);

      final fetched = await repository.getById(created.id);
      expect(fetched!.amount, 200);
    });

    test('delete removes the expense', () async {
      final created = await repository.create(Expense(
        amount: 50,
        categoryId: 1,
        expenseType: ExpenseType.home,
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

      await repository.delete(created.id);
      final fetched = await repository.getById(created.id);
      expect(fetched, isNull);
    });

    test('query filters by expenseType', () async {
      await repository.create(Expense(
        amount: 10,
        categoryId: 1,
        expenseType: ExpenseType.personal,
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));
      await repository.create(Expense(
        amount: 20,
        categoryId: 1,
        expenseType: ExpenseType.home,
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

      final results = await repository.query(
        const ExpenseQueryParams(expenseType: ExpenseType.home),
      );

      expect(results, hasLength(1));
      expect(results.single.expenseType, ExpenseType.home);
    });

    // PBT-02 Round-trip property (identified in business-rules.md):
    // writing any valid Expense and reading it back yields an equal object.
    Glados(anyExpense).test(
      'round-trip: create then getById always returns an equal expense',
      (expense) async {
        final created = await repository.create(expense);
        final fetched = await repository.getById(created.id);

        expect(fetched, isNotNull);
        expect(fetched!.amount, created.amount);
        expect(fetched.categoryId, created.categoryId);
        expect(fetched.expenseType, created.expenseType);
        expect(fetched.description, created.description);
        expect(fetched.tags, created.tags);
        expect(fetched.date, created.date);
      },
    );
  });
}
