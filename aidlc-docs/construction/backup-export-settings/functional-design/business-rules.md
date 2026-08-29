# Business Rules — Unit 6: Backup, Export & Settings

## BR-27: Backup Contents (requirements.md FR-8.1)
**Rule**: A backup archive contains, at minimum: all Expense rows, all Category rows, all Budget rows, Settings, and a `manifest.json` describing the contents. Receipt images are explicitly out of scope (PRD Future Roadmap V2).

## BR-28: Backup Retention Policy (resolves Application Design open item #2)
**Decision**: `BackupService.pruneOldBackups()` keeps the most recent 7 automatic nightly backups and deletes older ones. Manual backups (created via `createManualBackup`) are never auto-pruned — only the automatic nightly ones.
**Rationale**: 7 days gives a meaningful rollback window without unbounded storage growth; manual backups are explicit user actions the user is trusted to manage themselves (e.g., before uninstalling, exporting to external storage).

## BR-29: Restore Validates Before Mutating (fail-safe restore)
**Rule**: `restoreFromBackup` first extracts and validates `manifest.json` (checks it's parseable JSON with the expected fields) before touching any Isar collection. If validation fails, the restore aborts with an error and the existing database is completely untouched (stories.md US-20 AC4).
**Enforced by**: BackupService performs the entire restore (clear + reload of all 4 collections) inside a single Isar write transaction — if any step fails partway, the transaction rolls back and existing data is preserved (extends Unit 1's BR-6 transactional pattern).

## BR-30: Export Always Covers All Data (resolves Application Design open item #3)
**Decision**: `ExportService`'s CSV/Excel/JSON exports always export the full dataset, ignoring any active Expense List filter. The `ExpenseFilter?` parameter on `exportToCsv`/`exportToExcel`/`exportToJson` (from component-methods.md) is honored when explicitly supplied by the caller, but the default UI action ("Export" in Settings) always passes `null` (no filter) — filtered export from the Expense List screen itself is out of scope for this pass.
**Rationale**: Simpler mental model for a personal-finance export ("give me everything") and avoids a confusing surprise where an export silently omits data the user forgot was filtered.

## BR-31: Export Failure Leaves No Partial File
**Rule**: Export operations write to a temporary file first and only move/rename it to the final destination on success — a failure mid-write never leaves a corrupted, partially-written file at the user-visible path (stories.md US-21 AC3).

## BR-32: Custom Category Icon/Color Picker (US-06, Settings screen portion)
**Rule**: The Settings screen's "Manage Categories" section exposes create/delete for custom categories with a full icon and color picker (requirements.md decision, application-design-plan.md Q2's related decision), calling `CategoryService.createCustomCategory`/`deleteCategory` (Unit 1) — no new business logic, purely UI wiring.

## Testable Properties (PBT-01, PBT-02 round-trip emphasis)

| Property | Category | Applies To | Statement |
|---|---|---|---|
| Backup round-trip | Round-trip | createManualBackup → restoreFromBackup | For any generated set of expenses/categories/budgets/settings, backing up then restoring into a fresh database yields data equal to the original (PBT-02, the flagship round-trip property for this unit) |
| Export round-trip (JSON) | Round-trip | exportToJson → (hypothetical import) | JSON export followed by JSON parse recovers the original expense field values (no import feature exists yet, so this is tested as serialize→deserialize equality, not a full app round-trip) |
| Retention invariant | Invariant | pruneOldBackups | After pruning, at most 7 automatic backups remain, and no manual backup is ever removed |
