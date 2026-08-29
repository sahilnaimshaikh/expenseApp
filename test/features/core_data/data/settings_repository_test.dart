import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/core_data/data/settings_repository.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/core_data/domain/models/settings.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('SettingsRepository', () {
    late Isar isar;
    late SettingsRepository repository;

    setUp(() async {
      isar = await openTestIsar();
      repository = SettingsRepository(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    // BR-5 singleton enforcement.
    test('getSettings lazily creates the singleton row with defaults on first access', () async {
      final settings = await repository.getSettings();

      expect(settings.id, Settings.singletonId);
      expect(settings.currency, 'INR');
      expect(settings.theme, AppThemeMode.system);
      expect(settings.onboardingComplete, isFalse);
    });

    test('getSettings called repeatedly never creates more than one row', () async {
      await repository.getSettings();
      await repository.getSettings();
      await repository.getSettings();

      final count = await isar.settings.count();
      expect(count, 1);
    });

    test('updateSettings always writes to the singleton id, never creating a second row', () async {
      final settings = await repository.getSettings();
      settings.currency = 'USD';
      settings.onboardingComplete = true;

      await repository.updateSettings(settings);

      final count = await isar.settings.count();
      expect(count, 1);

      final refreshed = await repository.getSettings();
      expect(refreshed.currency, 'USD');
      expect(refreshed.onboardingComplete, isTrue);
    });
  });
}
