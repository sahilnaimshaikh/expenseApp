import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/models/budget.dart';
import '../domain/models/category.dart';
import '../domain/models/expense.dart';
import '../domain/models/settings.dart';

/// Opens the single, app-wide Isar instance registering all four core
/// schemas. Per nfr-design-patterns.md's "Isar instance provider" pattern,
/// no repository opens its own connection — every repository depends on
/// this provider.
///
/// A [FutureProvider] (not a plain [Provider]) is used deliberately so
/// dependents can `await ref.watch(isarInstanceProvider.future)` and get a
/// single cached, memoized instance rather than re-opening Isar on every
/// read.
final FutureProvider<Isar> isarInstanceProvider = FutureProvider<Isar>((ref) async {
  final directory = await getApplicationDocumentsDirectory();
  return Isar.open(
    [ExpenseSchema, BudgetSchema, CategorySchema, SettingsSchema],
    directory: directory.path,
  );
});
