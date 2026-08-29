# Unit Test Execution — Expense Tracker

## Test Inventory

All tests are under `test/`, mirroring `lib/features/` structure. Generated across all 7 units:

| Unit | Test Files |
|---|---|
| 1. Core Data & Categories | `expense_repository_test.dart`, `budget_repository_test.dart`, `category_repository_test.dart`, `settings_repository_test.dart`, `budget_service_test.dart`, `category_service_test.dart` |
| 2. Onboarding & Expense Management | `expense_service_test.dart`, `settings_service_test.dart` |
| 3. Budgeting & Notifications | `budget_service_threshold_test.dart` |
| 4. Dashboard | `dashboard_state_test.dart` |
| 5. Search, Filter, Sort & Reporting | `expense_service_search_filter_test.dart`, `report_service_test.dart` |
| 6. Backup, Export & Settings | `backup_service_test.dart`, `export_service_test.dart` |
| 7. Premium Polish | None (no new business logic; see build-and-test-summary.md for rationale) |

Tests include both example-based tests (pinning specific scenarios and business rules, tagged with their BR-number in comments) and property-based tests using `glados` (tagged PBT in comments), per the Property-Based Testing extension enabled for this project.

## Run Unit Tests

### 1. Ensure Isar codegen has run first
Tests import the generated `*.g.dart` files transitively via the model files — `build_runner` must have completed successfully (see build-instructions.md Step 2) before tests can compile.

### 2. Execute All Unit Tests
```bash
flutter test
```

### 3. Execute Tests for a Single Unit (example)
```bash
flutter test test/features/core_data/
flutter test test/features/expense_management/
flutter test test/features/core_data/domain/budget_service_threshold_test.dart
```

### 4. Run with Coverage
```bash
flutter test --coverage
# Generates coverage/lcov.info; view with genhtml (lcov) or an IDE coverage plugin
```

### 5. Review Test Results
- **Expected**: All tests pass (0 failures) on first successful `flutter pub get` + `build_runner` + `flutter test` run — however, since this codebase has never been compiled, some tests may reveal API-usage mistakes (e.g., incorrect Isar query-builder method names) that must be fixed before they pass. Treat the first test run as a verification pass, not a guaranteed-green pass.
- **Test Coverage**: No formal target set; prioritize coverage of all documented BR-numbered business rules (each should have at least one direct test) and all 3 code-summary-flagged PBT properties per unit.
- **Test Report Location**: Console output by default; `coverage/lcov.info` if run with `--coverage`.

### 6. Fix Failing Tests
If tests fail on the first real run:
1. Read the failure — Isar query-builder API mismatches (e.g., `.categoryIdEqualTo()` not existing on the generated `QueryBuilder`) are the most likely class of first-run failure, since the exact generated method names depend on Isar's codegen output, which could not be inspected in this development environment.
2. Cross-reference the failing repository method against the corresponding `*.g.dart` file's generated extension methods.
3. Fix the query builder call in the repository (not the test) if the business intent is still correct — the test encodes the desired behavior; the repository implementation is what to adjust.
4. Re-run `flutter test` for that file until green, then run the full suite again.

## Known Gaps for This Pass
- `backup_service_test.dart` and `export_service_test.dart` write real files to the system temp directory / a `backupsDirectoryOverride` seam — verify these tests clean up their temp files even on failure (some manual cleanup logic was added but not verified without a live test run).
- Widget-level tests (pumping actual screens, tapping buttons) were **not** written for any unit — see integration-test-instructions.md for the recommended follow-up.
