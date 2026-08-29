import 'package:isar/isar.dart';

part 'category.g.dart';

/// An expense category, either one of the 13 PRD-seeded defaults
/// ([isDefault] = true) or user-created ([isDefault] = false).
///
/// Business rules (see business-rules.md):
/// - BR-1: [name] must be unique case-insensitively (enforced by
///   CategoryService, not by this schema — Isar's index below is
///   case-sensitive and only accelerates lookups).
/// - BR-2: rows with [isDefault] == true cannot be deleted or renamed.
@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String name;

  String icon;

  String color;

  bool isDefault;

  Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.isDefault,
  });
}

/// The 13 PRD-specified default categories (PRD Section 5.1), seeded via
/// [CategoryService.ensureDefaultsSeeded].
class DefaultCategories {
  DefaultCategories._();

  static const List<({String name, String icon, String color})> all = [
    (name: 'Food', icon: 'restaurant', color: '#FF7043'),
    (name: 'Groceries', icon: 'shopping_cart', color: '#66BB6A'),
    (name: 'Fuel', icon: 'local_gas_station', color: '#FFA726'),
    (name: 'Utilities', icon: 'bolt', color: '#42A5F5'),
    (name: 'Shopping', icon: 'shopping_bag', color: '#AB47BC'),
    (name: 'Medical', icon: 'local_hospital', color: '#EF5350'),
    (name: 'Education', icon: 'school', color: '#26A69A'),
    (name: 'Travel', icon: 'flight', color: '#5C6BC0'),
    (name: 'Entertainment', icon: 'movie', color: '#EC407A'),
    (name: 'Investment', icon: 'trending_up', color: '#7CB342'),
    (name: 'Rent', icon: 'home', color: '#8D6E63'),
    (name: 'Gifts', icon: 'card_giftcard', color: '#F06292'),
    (name: 'Others', icon: 'category', color: '#78909C'),
  ];

  static const String fallbackCategoryName = 'Others';
}
