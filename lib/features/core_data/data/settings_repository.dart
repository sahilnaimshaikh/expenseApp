import 'package:isar/isar.dart';

import '../domain/models/settings.dart';
import '../domain/repository_exception.dart';

/// Repository over the Isar `Settings` collection.
///
/// Enforces BR-5 (singleton): no create/delete is exposed. [getSettings]
/// lazily creates the single row (with defaults) on first access if it
/// doesn't exist yet, and [updateSettings] always writes to the fixed
/// [Settings.singletonId].
class SettingsRepository {
  SettingsRepository(this._isar);

  final Isar _isar;

  Future<Settings> getSettings() async {
    try {
      final existing = await _isar.settings.get(Settings.singletonId);
      if (existing != null) return existing;

      final defaults = Settings();
      await _isar.writeTxn(() async {
        await _isar.settings.put(defaults);
      });
      return defaults;
    } catch (e) {
      throw RepositoryException(
        operation: 'Settings.getSettings',
        message: "Couldn't load your settings. Please try again.",
        cause: e,
      );
    }
  }

  Future<Settings> updateSettings(Settings settings) async {
    try {
      settings.id = Settings.singletonId;
      await _isar.writeTxn(() async {
        await _isar.settings.put(settings);
      });
      return settings;
    } catch (e) {
      throw RepositoryException(
        operation: 'Settings.updateSettings',
        message: "Couldn't save your settings. Please try again.",
        cause: e,
      );
    }
  }
}
