# Code Summary — Unit 6: Backup, Export & Settings

## Application Code Created
- `lib/features/backup_export/domain/backup_manifest.dart` — `BackupManifest`
- `lib/features/backup_export/domain/backup_service.dart` — `BackupService`, `BackupException`
- `lib/features/backup_export/domain/export_format.dart` — `ExportFormat`
- `lib/features/backup_export/domain/export_service.dart` — `ExportService`
- `lib/features/backup_export/domain/backup_export_providers.dart` — providers for both services
- `lib/features/backup_export/domain/background_backup_task.dart` — workmanager registration/dispatcher (partially deferred, see gaps)
- `lib/features/settings/presentation/settings_controller.dart` — `SettingsScreenController`
- `lib/features/settings/presentation/settings_screen.dart` — `SettingsScreen`
- `lib/features/settings/presentation/add_category_dialog.dart` — `showAddCategoryDialog`

## Application Code Modified/Extended
- `lib/features/core_data/data/expense_repository.dart` — added `getAll()`, `replaceAll()`
- `lib/features/core_data/data/category_repository.dart` — added `replaceAll()`
- `lib/features/core_data/data/budget_repository.dart` — added `getAll()`, `replaceAll()`
- `lib/features/onboarding/domain/settings_service.dart` — added `getSettings`, `updateTheme`, `updateCurrency`, `updateNotificationPreferences`
- `lib/main.dart` — registers the nightly backup task at startup (fail-safe, fire-and-forget)
- `lib/app_router.dart` — Settings tab now uses the real `SettingsScreen`

## Tests Created
- `test/features/backup_export/domain/backup_service_test.dart` — BR-28/29 example tests + the flagship backup-then-restore-into-fresh-database round-trip test (PBT-02)
- `test/features/backup_export/domain/export_service_test.dart` — BR-30/31 example tests for CSV/JSON export

## Design Notes
- Repository `getAll`/`replaceAll` additions keep the "thin repository" principle intact — they're still pure CRUD-shaped operations, just unscoped, needed specifically for whole-dataset backup/restore.
- `BackupService` takes an optional `backupsDirectoryOverride` constructor parameter specifically to make it testable without `path_provider`'s platform channel — a deliberate test-seam addition, not a production behavior change (defaults to `path_provider` when omitted).

## Known Gaps (flagged, not silently skipped)
1. **Restore file-picker UI**: `settings_screen.dart`'s restore button currently shows an informational dialog rather than a working file picker — `file_picker`'s platform channel can't be exercised without the Flutter SDK/a device. `BackupService.restoreFromBackup(File)` itself is fully implemented and tested; only the UI's file-selection step is deferred.
2. **Background isolate Isar reopening**: `background_backup_task.dart`'s `_openIsarForBackground()` throws `UnimplementedError` — the correct directory path for a workmanager background isolate to reopen the same Isar instance needs on-device verification; this is a known limitation of developing without the SDK, not a design gap.

## Known Limitation
Same SDK-unavailability caveat as prior units — compounded here since `path_provider`, `file_picker`, and `workmanager` all rely on platform channels that literally cannot function without a device/emulator, regardless of SDK availability. These two items above are the concrete manifestation of that limitation for this unit.
