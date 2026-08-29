# Code Generation Plan — Unit 6: Backup, Export & Settings

## Unit Context
- **Stories implemented**: US-20, US-21, US-22, plus US-06's custom-category UI portion
- **Dependencies**: Unit 1 (all 4 repositories, CategoryService)
- **Extends**: Unit 2's SettingsService (ongoing-settings methods)

## Steps
- [x] Step 1: Project structure — `lib/features/backup_export/`, `lib/features/settings/`
- [x] Step 2: Business Logic Generation — BackupManifest, BackupService, ExportFormat, ExportService, extended SettingsService, extended ExpenseRepository/CategoryRepository/BudgetRepository with getAll/replaceAll for backup support
- [x] Step 3: Business Logic Unit Testing — BR-27/28/29/31 example tests + a full backup-then-restore round-trip test (the flagship PBT-02 property for this unit, written as a concrete example given the complexity of generating full cross-entity backup archives); ExportService BR-30 example tests
- [x] Step 4-7: Summaries — this file + code-summary.md
- [x] Step 8: Frontend Components Generation — SettingsScreen, SettingsScreenController, AddCategoryDialog (BR-32's icon/color picker)
- [x] Step 9: Frontend Components Unit Testing — deferred (consistent with prior units); restore file-picker UI wiring explicitly deferred as a documented TODO (file_picker platform channel requires the SDK)
- [x] Step 10: Documentation — dartdoc, explicit notes on the deferred restore file-picker wiring and the background-isolate Isar-reopen TODO
- [x] Step 11: Deployment Artifacts — N/A

## Story Traceability
| Story | Implementation |
|---|---|
| US-06 (custom category UI) | AddCategoryDialog, SettingsScreen's category list |
| US-20 | BackupService, settings-backup-now-button, background_backup_task.dart |
| US-21 | ExportService, settings-export-*-buttons |
| US-22 | SettingsService (extended), SettingsScreen |

## Known Gaps Flagged for Build and Test / Future Work
1. Restore's file-picker UI (`_showRestorePicker` in settings_screen.dart) shows a placeholder dialog — `file_picker` platform-channel wiring needs the actual Flutter SDK/device to implement and verify.
2. `background_backup_task.dart`'s `_openIsarForBackground()` throws `UnimplementedError` — determining the correct Isar directory path inside a workmanager background isolate needs on-device verification.
