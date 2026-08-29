import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, setUp, tearDown, setUpAll, tearDownAll, expect;
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/core_data/data/category_repository.dart';
import 'package:expense_tracker/features/core_data/domain/models/category.dart';

import '../../../helpers/isar_test_helper.dart';

Generator<Category> get anyCustomCategory => any.combine3(
      any.letterOrDigits.map((s) => s.isEmpty ? 'cat' : s),
      any.letterOrDigits.map((s) => s.isEmpty ? 'icon' : s),
      any.letterOrDigits.map((s) => s.isEmpty ? '#000000' : '#$s'),
      (String name, String icon, String color) => Category(
        name: name,
        icon: icon,
        color: color,
        isDefault: false,
      ),
    );

void main() {
  group('CategoryRepository', () {
    late Isar isar;
    late CategoryRepository repository;

    setUp(() async {
      isar = await openTestIsar();
      repository = CategoryRepository(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('seedDefaults inserts exactly the 13 PRD default categories', () async {
      await repository.seedDefaults();
      final all = await repository.getAll();
      expect(all, hasLength(13));
    });

    test('seedDefaults is idempotent', () async {
      await repository.seedDefaults();
      await repository.seedDefaults();
      final all = await repository.getAll();
      expect(all, hasLength(13));
    });

    test('getByName matches case-insensitively', () async {
      await repository.create(Category(name: 'Pets', icon: 'pets', color: '#000', isDefault: false));
      final found = await repository.getByName('pets');
      expect(found, isNotNull);
      expect(found!.name, 'Pets');
    });

    test('delete removes the category', () async {
      final created = await repository.create(
        Category(name: 'Temp', icon: 'x', color: '#000', isDefault: false),
      );
      await repository.delete(created.id);
      final found = await repository.getByName('Temp');
      expect(found, isNull);
    });

    // PBT-02 round-trip property.
    Glados(anyCustomCategory).test(
      'round-trip: create then getByName returns an equal category',
      (category) async {
        // Ensure uniqueness across generated cases within one Isar instance
        // by giving each a fresh instance — keeps the property about
        // round-trip fidelity, not about BR-1 collision handling (covered
        // separately in category_service_test.dart).
        final freshIsar = await openTestIsar();
        try {
          final freshRepo = CategoryRepository(freshIsar);
          final created = await freshRepo.create(category);
          final fetched = await freshRepo.getByName(created.name);

          expect(fetched, isNotNull);
          expect(fetched!.name, created.name);
          expect(fetched.icon, created.icon);
          expect(fetched.color, created.color);
          expect(fetched.isDefault, created.isDefault);
        } finally {
          await freshIsar.close(deleteFromDisk: true);
        }
      },
    );
  });
}
