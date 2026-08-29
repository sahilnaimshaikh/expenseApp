import '../../core_data/data/category_repository.dart';
import '../../core_data/data/expense_repository.dart';
import '../../core_data/domain/models/category.dart';

/// Thrown when a business rule in [CategoryService] is violated.
class CategoryValidationException implements Exception {
  const CategoryValidationException(this.message);

  final String message;

  @override
  String toString() => 'CategoryValidationException: $message';
}

/// Business logic for category lifecycle: default seeding, custom category
/// creation, and deletion with the BR-3 reassignment rule.
///
/// See aidlc-docs/construction/core-data-categories/functional-design/business-rules.md
/// for BR-1 through BR-4, and business-logic-model.md Process 2 for the
/// flows this class implements.
class CategoryService {
  CategoryService(this._categoryRepository, this._expenseRepository);

  final CategoryRepository _categoryRepository;
  final ExpenseRepository _expenseRepository;

  /// BR-4: idempotent — safe to call on every app launch.
  Future<void> ensureDefaultsSeeded() async {
    await _categoryRepository.seedDefaults();
  }

  /// BR-1: rejects a name that matches any existing category
  /// case-insensitively, before ever calling the repository.
  Future<Category> createCustomCategory({
    required String name,
    required String icon,
    required String color,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const CategoryValidationException('Category name cannot be empty.');
    }

    final existing = await _categoryRepository.getByName(trimmedName);
    if (existing != null) {
      throw CategoryValidationException(
        'A category named "${existing.name}" already exists.',
      );
    }

    final category = Category(
      name: trimmedName,
      icon: icon,
      color: color,
      isDefault: false,
    );
    return _categoryRepository.create(category);
  }

  /// BR-2 (default protection) + BR-3 (reassign-then-delete for custom
  /// categories with existing expenses).
  Future<void> deleteCategory(int id) async {
    final categories = await _categoryRepository.getAll();
    final target = categories.where((c) => c.id == id).firstOrNullSafe();

    if (target == null) {
      // Nothing to do — already absent. Treated as a successful no-op
      // rather than an error, since the end state (category gone) holds.
      return;
    }

    if (target.isDefault) {
      throw const CategoryValidationException(
        'Default categories cannot be deleted.',
      );
    }

    final affected = await _expenseRepository.query(
      ExpenseQueryParams(categoryId: id, limit: 1000000),
    );

    if (affected.isNotEmpty) {
      final fallback = await _categoryRepository.getByName(
        DefaultCategories.fallbackCategoryName,
      );
      if (fallback == null) {
        throw const CategoryValidationException(
          'Cannot delete this category: the "Others" fallback category is missing. '
          'Run default category seeding first.',
        );
      }

      for (final expense in affected) {
        expense.categoryId = fallback.id;
        expense.updatedAt = DateTime.now();
        await _expenseRepository.update(expense);
      }
    }

    await _categoryRepository.delete(id);
  }
}

extension _FirstOrNullSafe<T> on Iterable<T> {
  T? firstOrNullSafe() {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
