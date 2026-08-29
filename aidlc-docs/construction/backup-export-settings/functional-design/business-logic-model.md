# Business Logic Model — Unit 6: Backup, Export & Settings

## Process 1: Manual Backup (US-20.2)
1. Fetch all Expense/Category/Budget rows + Settings from their repositories.
2. Serialize each to JSON.
3. Build a `manifest.json` (BR-27).
4. Zip everything into a single archive (via the `archive` package) at a temp path, then move to the final destination (BR-31's temp-then-move pattern, reused from export).

## Process 2: Automatic Nightly Backup (US-20.1)
Same as Process 1, but triggered by a platform scheduler (via `workmanager`, NFR Design's decision) and written to app-private storage rather than a user-chosen location. Followed immediately by `pruneOldBackups()` (BR-28).

## Process 3: Restore (US-20.3, US-20.4)
1. Extract the archive to a temp directory.
2. Parse and validate `manifest.json` (BR-29). Abort here on any validation failure — no Isar writes yet.
3. Parse each entity JSON file.
4. Inside a single `isar.writeTxn()`: clear all 4 collections, then bulk-insert the restored data.
5. On any exception during step 4, the transaction rolls back automatically (Isar's transaction semantics) — existing data survives untouched.

## Process 4: Export (US-21)
1. Fetch all Expense rows (BR-30: unfiltered by default) + resolve category names for human-readable output.
2. Format per the requested `ExportFormat`:
   - CSV: via the `csv` package.
   - Excel: via the `excel` package.
   - JSON: direct `jsonEncode`.
3. Write to a temp file, then move to final destination (BR-31).

## Process 5: Settings (Ongoing Portion, US-22)
Extends Unit 2's `SettingsService` (not a new class) with `updateTheme`, `updateCurrency`, `updateNotificationPreferences` — each a straightforward read-modify-write via `SettingsRepository`.

## Process 6: Custom Category Management UI (US-06 UI portion)
Settings screen section wiring `CategoryService.createCustomCategory`/`deleteCategory` (Unit 1) to a UI with an icon/color picker (BR-32) — no new service logic.

## Error Scenarios
| Scenario | Handling |
|---|---|
| Restore from a corrupted/non-backup ZIP | BR-29 — manifest validation fails, restore aborts, existing data untouched, clear error shown |
| Export fails mid-write (e.g., storage full) | BR-31 — temp file discarded, no corrupted file left at the destination |
| Attempt to delete a category still in use during Settings management | Delegates to Unit 1's `CategoryService.deleteCategory`, which already implements BR-3's reassign-to-Others behavior |

## Frontend Components

### Settings Screen (US-22)
- **Hierarchy**: `SettingsScreen` → `ThemeSection` → `CurrencySection` → `NotificationPreferencesSection` → `ManageCategoriesSection` (list + add/delete with icon/color picker) → `BackupRestoreSection` → `ExportSection` → `AboutSection`
- **State**: `SettingsScreenController` — `settings: Settings`, `categories: List<Category>`, `isBusy`
- **Automation-friendly Keys**: `settings-theme-selector`, `settings-currency-input`, `settings-notifications-toggle`, `settings-manage-categories-list`, `settings-add-category-button`, `settings-backup-now-button`, `settings-restore-button`, `settings-export-csv-button`, `settings-export-excel-button`, `settings-export-json-button`

### Custom Category Dialog (US-06 UI, BR-32)
- **Hierarchy**: `AddCategoryDialog` → `NameField` → `IconPicker` → `ColorPicker` → `SaveButton`
- **Automation-friendly Keys**: `add-category-name-input`, `add-category-icon-picker`, `add-category-color-picker`, `add-category-save-button`
