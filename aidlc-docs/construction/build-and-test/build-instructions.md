# Build Instructions — Expense Tracker

## Prerequisites
- **Build Tool**: Flutter SDK (stable channel), Dart >=3.4.0 <4.0.0
- **Dependencies**: All declared in [pubspec.yaml](../../../pubspec.yaml) — Isar, Riverpod, Go Router, FL Chart, flutter_local_notifications, decimal, archive, csv, excel, share_plus, file_picker, flutter_colorpicker, workmanager, plus dev dependencies (isar_generator, build_runner, riverpod_generator, glados, mocktail)
- **Environment Variables**: None required (fully offline app, no API keys/secrets)
- **System Requirements**: Android SDK (API 21+ minimum for the target dependencies; API 26+ recommended for full notification-channel behavior), Android Studio or VS Code with Flutter/Dart plugins, an Android emulator or physical device for running/testing UI

**Note on this codebase's origin**: All application code and tests in this repository were authored in a development environment **without** the Flutter/Dart SDK installed. No command in this document has been executed in this session — every file was reviewed logically for correctness but not machine-verified. Running the steps below for the first time is the first real compilation/test-execution this codebase will undergo.

## Build Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Isar Schema Code
Isar's `@collection` classes (Expense, Budget, Category, Settings) require generated `*.g.dart` files, which are **not** checked into this repository (see `.gitignore`).
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
Expected output: `Succeeded after ... with N outputs` — one `.g.dart` file per model in `lib/features/core_data/domain/models/`.

### 3. Configure Environment
No environment variables or credentials are required — this is a fully offline app with no backend.

If targeting Android, ensure a device/emulator is connected:
```bash
flutter devices
```

### 4. Build the App
```bash
# Debug build, for development/testing:
flutter run

# Release APK:
flutter build apk --release

# Release App Bundle (for Play Store):
flutter build appbundle --release
```

### 5. Verify Build Success
- **Expected Output**: `flutter build apk --release` reports `Built build/app/outputs/flutter-apk/app-release.apk`
- **Build Artifacts**: `build/app/outputs/flutter-apk/*.apk` or `build/app/outputs/bundle/release/*.aab`
- **Common Warnings**: Deprecation warnings from third-party packages (e.g., `isar_flutter_libs`) are expected and non-blocking; a warning about `workmanager`'s Android 12+ exact-alarm permission may appear and is expected given the nightly-backup feature

## Troubleshooting

### Build Fails with "Target of URI doesn't exist" for any `package:...` import
- **Cause**: `flutter pub get` was not run, or `pubspec.yaml`'s dependency versions are unavailable/incompatible with the installed Flutter SDK version
- **Solution**: Run `flutter pub get`. If a specific package version fails to resolve, run `flutter pub outdated` and adjust the pinned version in `pubspec.yaml` to the nearest compatible release — this codebase pinned specific versions without access to `pub.dev`'s live resolver, so minor version adjustments may be needed on first build.

### Build Fails with "The name 'X' isn't a type" or Isar-generator errors referencing `*.g.dart`
- **Cause**: `build_runner` was not run, or ran before all model files existed
- **Solution**: Re-run `flutter pub run build_runner build --delete-conflicting-outputs`. If it fails on a specific model, check that the model's `part '...g.dart';` directive matches its filename exactly.

### Android build fails on `workmanager` or `flutter_local_notifications` manifest merge
- **Cause**: These plugins require specific `AndroidManifest.xml` entries (permissions, receivers) that are added automatically by their own Gradle plugins on `flutter pub get`, but may need `minSdkVersion` raised in `android/app/build.gradle` if the default Flutter template's minSdkVersion is below 21
- **Solution**: Set `minSdkVersion 21` (or higher) in `android/app/build.gradle`, then rebuild.

### Excel/CSV export or ZIP backup fails on-device with a file-permission error
- **Cause**: Android's scoped storage restrictions (Android 10+) may require additional handling not yet implemented (this codebase writes to `getApplicationDocumentsDirectory()`, which is app-private and should not require extra permissions — but flagged here since it's untested on a real device)
- **Solution**: Verify writes to app-private storage first; only add `MANAGE_EXTERNAL_STORAGE` or similar permissions if a genuine need to write to shared storage is confirmed during testing.
