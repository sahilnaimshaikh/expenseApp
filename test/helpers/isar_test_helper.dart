import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

import 'package:expense_tracker/features/core_data/domain/models/budget.dart';
import 'package:expense_tracker/features/core_data/domain/models/category.dart';
import 'package:expense_tracker/features/core_data/domain/models/expense.dart';
import 'package:expense_tracker/features/core_data/domain/models/settings.dart';

/// Opens a fresh, isolated in-memory-style Isar instance for a single test.
///
/// Each call uses a unique temp directory name so parallel tests never
/// collide, and callers are responsible for calling `isar.close(deleteFromDisk: true)`
/// in a `tearDown`.
Future<Isar> openTestIsar() async {
  final dir = await Directory.systemTemp.createTemp('expense_tracker_test_');
  return Isar.open(
    [ExpenseSchema, BudgetSchema, CategorySchema, SettingsSchema],
    directory: dir.path,
    name: p.basename(dir.path),
  );
}
