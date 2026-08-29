import 'package:isar/isar.dart';

import '../domain/models/category.dart';
import '../domain/repository_exception.dart';

/// Thin CRUD repository over the Isar `Category` collection.
class CategoryRepository {
  CategoryRepository(this._isar);

  final Isar _isar;

  Future<List<Category>> getAll() async {
    try {
      return await _isar.categorys.where().findAll();
    } catch (e) {
      throw RepositoryException(
        operation: 'Category.getAll',
        message: "Couldn't load your categories. Please try again.",
        cause: e,
      );
    }
  }

  Future<Category?> getByName(String name) async {
    try {
      // Isar's built-in index/EqualTo is case-sensitive; case-insensitive
      // matching (BR-1) is done in Dart at the CategoryService layer, not
      // here, since this repository stays a thin storage wrapper.
      final all = await getAll();
      final matches = all.where((c) => c.name.toLowerCase() == name.toLowerCase());
      return matches.isEmpty ? null : matches.first;
    } catch (e) {
      throw RepositoryException(
        operation: 'Category.getByName',
        message: "Couldn't look up this category. Please try again.",
        cause: e,
      );
    }
  }

  Future<Category> create(Category category) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.categorys.put(category);
      });
      return category;
    } catch (e) {
      throw RepositoryException(
        operation: 'Category.create',
        message: "Couldn't save this category. Please try again.",
        cause: e,
      );
    }
  }

  Future<Category> update(Category category) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.categorys.put(category);
      });
      return category;
    } catch (e) {
      throw RepositoryException(
        operation: 'Category.update',
        message: "Couldn't update this category. Please try again.",
        cause: e,
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.categorys.delete(id);
      });
    } catch (e) {
      throw RepositoryException(
        operation: 'Category.delete',
        message: "Couldn't delete this category. Please try again.",
        cause: e,
      );
    }
  }

  /// Inserts the 13 PRD-specified default categories that don't already
  /// exist (by name). Safe to call repeatedly — see BR-4 (idempotence).
  Future<void> seedDefaults() async {
    try {
      final existing = await getAll();
      final existingNames = existing.map((c) => c.name.toLowerCase()).toSet();

      final toInsert = DefaultCategories.all
          .where((d) => !existingNames.contains(d.name.toLowerCase()))
          .map((d) => Category(name: d.name, icon: d.icon, color: d.color, isDefault: true))
          .toList();

      if (toInsert.isEmpty) return;

      await _isar.writeTxn(() async {
        await _isar.categorys.putAll(toInsert);
      });
    } catch (e) {
      throw RepositoryException(
        operation: 'Category.seedDefaults',
        message: "Couldn't set up default categories. Please try again.",
        cause: e,
      );
    }
  }

  /// Replaces every Category row with [categories] inside a single
  /// transaction — used only by [BackupService.restoreFromBackup].
  Future<void> replaceAll(List<Category> categories) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.categorys.clear();
        await _isar.categorys.putAll(categories);
      });
    } catch (e) {
      throw RepositoryException(
        operation: 'Category.replaceAll',
        message: "Couldn't restore your categories. Please try again.",
        cause: e,
      );
    }
  }
}
