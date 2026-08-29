import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/backup_export/domain/export_service.dart';
import 'package:expense_tracker/features/core_data/data/category_repository.dart';
import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/domain/models/category.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/core_data/domain/models/expense.dart';
import 'package:expense_tracker/features/expense_management/domain/expense_filter.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('ExportService', () {
    late Isar isar;
    late Directory tempDir;
    late ExpenseRepository expenseRepository;
    late CategoryRepository categoryRepository;
    late ExportService service;
    late int categoryId;

    setUp(() async {
      isar = await openTestIsar();
      tempDir = await Directory.systemTemp.createTemp('export_test_');
      expenseRepository = ExpenseRepository(isar);
      categoryRepository = CategoryRepository(isar);
      service = ExportService(
        expenseRepository,
        categoryRepository,
        documentsDirectoryOverride: tempDir.path,
      );

      final category = await categoryRepository.create(
        Category(name: 'Food', icon: 'x', color: '#000', isDefault: true),
      );
      categoryId = category.id;

      await expenseRepository.create(Expense(
        amount: 99.99,
        categoryId: categoryId,
        expenseType: ExpenseType.personal,
        date: DateTime(2026, 6, 1),
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
        description: 'Dinner',
      ));
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('exportToJson writes valid JSON containing the expense data', () async {
      final file = await service.exportToJson(null);
      expect(await file.exists(), isTrue);

      final content = await file.readAsString();
      final decoded = jsonDecode(content) as List<dynamic>;
      expect(decoded, hasLength(1));
      expect(decoded.single['amount'], 99.99);
      expect(decoded.single['category'], 'Food');

      await file.parent.delete(recursive: true);
    });

    test('exportToCsv writes a header row plus one data row', () async {
      final file = await service.exportToCsv(null);
      final content = await file.readAsString();
      final lines = content.trim().split('\n');

      expect(lines, hasLength(2));
      expect(lines.first, contains('Date'));
      expect(lines[1], contains('99.99'));

      await file.parent.delete(recursive: true);
    });

    // BR-30: export always covers all data by default (null filter).
    test('null filter exports all expenses regardless of any UI filter state', () async {
      await expenseRepository.create(Expense(
        amount: 5,
        categoryId: categoryId,
        expenseType: ExpenseType.home,
        date: DateTime(2020, 1, 1),
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
      ));

      final file = await service.exportToJson(null);
      final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
      expect(decoded, hasLength(2));

      await file.parent.delete(recursive: true);
    });

    test('explicit filter restricts the export to matching expenses', () async {
      await expenseRepository.create(Expense(
        amount: 5,
        categoryId: categoryId,
        expenseType: ExpenseType.home,
        date: DateTime(2020, 1, 1),
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
      ));

      final file = await service.exportToJson(const ExpenseFilter(expenseType: ExpenseType.personal));
      final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
      expect(decoded, hasLength(1));
      expect(decoded.single['expenseType'], 'personal');

      await file.parent.delete(recursive: true);
    });
  });
}
