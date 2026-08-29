# Security Test Instructions — Expense Tracker

Per the enabled Security Baseline extension, this document covers the rules that are **applicable** to this offline, backend-less mobile app. See requirements.md and each unit's NFR Requirements for the full N/A determination table — this file only re-lists what's testable.

## Applicable Rules and How to Verify

### SECURITY-01 (Encryption at Rest) — Partial, Accepted Trade-off
- **What was decided**: No app-level Isar encryption (immature for the pinned Isar version); relies on Android's OS-level File-Based Encryption (default since Android 10).
- **Test**: On a rooted test device or emulator, confirm `getApplicationDocumentsDirectory()`'s backing storage is encrypted at the OS level (`adb shell getprop ro.crypto.state` should report `encrypted`). This validates the accepted trade-off's assumption, not app code.
- **Also verify**: Exported/manually-backed-up files (which leave app-private storage if the user shares them) are NOT separately encrypted — confirm the Settings screen displays the "Backup and export files are not encrypted" notice (added above the Backup/Restore section in `settings_screen.dart` during Build and Test prep).

### SECURITY-03 (Application-Level Logging, No PII)
- **Test**: Trigger various error paths (invalid expense amount, restore from corrupt backup, notification failure) and inspect `adb logcat` output. Confirm no expense description text, amounts, category names, or file paths appear in log output — only generic operation identifiers (e.g., `Expense.create`).

### SECURITY-09 (Hardening / Generic Error Messages)
- **Test**: Trigger `RepositoryException`, `BackupException`, `ExpenseValidationException`, etc., and confirm the UI-facing message is always the generic string defined in code (e.g., "Couldn't save your expense. Please try again.") — never the raw underlying exception's `toString()` or stack trace.

### SECURITY-10 (Supply Chain Security)
- **Test**:
  ```bash
  flutter pub outdated
  # Confirm pubspec.lock is committed (git ls-files pubspec.lock)
  ```
  Manually review that all dependencies in `pubspec.yaml` come from pub.dev's official registry (none do — this was already true by construction, since no custom/private package sources were used).

### SECURITY-11 (Secure Design — Separation of Concerns)
- **Test**: Code review only (already satisfied by the layered architecture) — confirm no business logic (validation, calculations) exists inside widget `build()` methods across any screen; all such logic should live in `*_controller.dart` or `*_service.dart` files.

### SECURITY-13 (Data Integrity — Safe Deserialization)
- **Test**: This is `BackupService.restoreFromBackup`'s core concern (BR-29). Run `backup_service_test.dart`'s "rejects a non-ZIP file without touching existing data" test — confirms untrusted backup input never reaches Isar without validation.
- **Additional manual test**: Craft a ZIP with a valid `manifest.json` but corrupted `expenses.json` (malformed JSON) and confirm restore aborts cleanly with no partial data written.

### SECURITY-15 (Fail-Safe Exception Handling)
- **Test**: Force each documented fail-safe path (notification dispatch failure, budget recalculation failure during expense deletion, background backup task failure) and confirm the app continues functioning — the triggering user action (save expense, delete expense) still succeeds even when its secondary side-effect fails.

## Confirmed N/A (No Test Needed)
SECURITY-02, 04, 05 (analog covered under input validation, not a literal API), 06, 07, 08, 12, 14 — all require network endpoints, cloud IAM, or user authentication, none of which exist in this app. See requirements.md's extension configuration table for the full rationale.

## Dependency Vulnerability Scanning
```bash
# No official `flutter pub audit` exists as of this writing; use:
dart pub outdated --mode=null-safety
# or a third-party tool like `osv-scanner` against pubspec.lock
```
