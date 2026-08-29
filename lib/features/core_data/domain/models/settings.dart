import 'package:isar/isar.dart';

import 'enums.dart';

part 'settings.g.dart';

/// App-wide settings. Enforced singleton — see BR-5: exactly one row ever
/// exists, always with [id] == [singletonId]. SettingsRepository never
/// exposes create/delete for this collection.
@collection
class Settings {
  Id id = singletonId;

  @enumerated
  AppThemeMode theme;

  String currency;

  bool notificationsEnabled;

  String? backupLocation;

  bool onboardingComplete;

  Settings({
    this.theme = AppThemeMode.system,
    this.currency = 'INR',
    this.notificationsEnabled = true,
    this.backupLocation,
    this.onboardingComplete = false,
  });

  /// The fixed id every Settings row must use (BR-5).
  static const Id singletonId = 1;
}
