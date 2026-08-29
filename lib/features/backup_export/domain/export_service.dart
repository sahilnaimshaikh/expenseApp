import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core_data/data/category_repository.dart';
import '../../core_data/data/expense_repository.dart';
import '../../core_data/domain/models/expense.dart';
import '../../expense_management/domain/expense_filter.dart';

/// One-way data export (US-21). Kept separate from [BackupService] per
/// Application Design's Q6 decision — export never writes back into the
/// app's own data.
///
/// BR-30: [filter] is honored when explicitly supplied, but all default
/// UI actions pass `null` — export always covers the full dataset unless
/// a caller deliberately opts into a filtered export.
class ExportService {
  ExportService(
    this._expenseRepository,
    this._categoryRepository, {
    String? documentsDirectoryOverride,
  }) : _documentsDirectoryOverride = documentsDirectoryOverride;

  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;
  final String? _documentsDirectoryOverride;

  Future<File> exportToCsv(ExpenseFilter? filter) async {
    final rows = await _rowsForExport(filter);
    final csv = const ListToCsvConverter().convert(rows);
    return _writeAtomically('expense_export_${_timestamp()}.csv', utf8.encode(csv));
  }

  Future<File> exportToExcel(ExpenseFilter? filter) async {
    final rows = await _rowsForExport(filter);

    final workbook = excel_pkg.Excel.createExcel();
    final sheet = workbook['Expenses'];
    for (final row in rows) {
      sheet.appendRow(row.map((v) => excel_pkg.TextCellValue(v.toString())).toList());
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw StateError('Failed to encode Excel workbook.');
    }
    return _writeAtomically('expense_export_${_timestamp()}.xlsx', bytes);
  }

  Future<File> exportToJson(ExpenseFilter? filter) async {
    final expenses = await _expensesForExport(filter);
    final categories = await _categoryRepository.getAll();
    final categoryNamesById = {for (final c in categories) c.id: c.name};

    final jsonList = expenses
        .map((e) => {
              'amount': e.amount,
              'category': categoryNamesById[e.categoryId] ?? 'Unknown',
              'expenseType': e.expenseType.name,
              'description': e.description,
              'paymentMethod': e.paymentMethod?.name,
              'tags': e.tags,
              'date': e.date.toIso8601String(),
            })
        .toList();

    return _writeAtomically('expense_export_${_timestamp()}.json', utf8.encode(jsonEncode(jsonList)));
  }

  Future<List<Expense>> _expensesForExport(ExpenseFilter? filter) async {
    if (filter == null) {
      return _expenseRepository.getAll();
    }
    return _expenseRepository.query(ExpenseQueryParams(
      startDate: filter.startDate,
      endDate: filter.endDate,
      categoryId: filter.categoryId,
      expenseType: filter.expenseType,
      paymentMethod: filter.paymentMethod,
      minAmount: filter.minAmount,
      maxAmount: filter.maxAmount,
      limit: 1000000,
    ));
  }

  Future<List<List<Object?>>> _rowsForExport(ExpenseFilter? filter) async {
    final expenses = await _expensesForExport(filter);
    final categories = await _categoryRepository.getAll();
    final categoryNamesById = {for (final c in categories) c.id: c.name};

    final header = ['Date', 'Amount', 'Category', 'Type', 'Description', 'Payment Method', 'Tags'];
    final rows = expenses
        .map((e) => [
              e.date.toIso8601String(),
              e.amount,
              categoryNamesById[e.categoryId] ?? 'Unknown',
              e.expenseType.name,
              e.description ?? '',
              e.paymentMethod?.name ?? '',
              e.tags.join(', '),
            ])
        .toList();

    return [header, ...rows];
  }

  /// BR-31: temp-then-move, same pattern as [BackupService].
  Future<File> _writeAtomically(String fileName, List<int> bytes) async {
    final basePath = _documentsDirectoryOverride ?? (await getApplicationDocumentsDirectory()).path;
    final finalPath = p.join(basePath, 'exports', fileName);
    final finalFile = File(finalPath);
    await finalFile.parent.create(recursive: true);

    final tempFile = File('$finalPath.tmp');
    await tempFile.writeAsBytes(bytes);
    return tempFile.rename(finalPath);
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
}
