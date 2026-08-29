# Integration Test Instructions — Expense Tracker

## Purpose
Test interactions between units/services to ensure they work together correctly — particularly the cross-unit orchestration seams explicitly documented during Code Generation (Unit 2's `AddEditExpenseController` extended by Unit 3; Unit 4's Dashboard aggregation superseded by Unit 5's ReportService; Unit 1's `BudgetService` split across Units 1 and 3).

**Note**: Since this app has no network boundary, "integration" here means widget-level integration tests (`flutter_test`'s `WidgetTester` pumping real widget trees with a real in-memory-style Isar instance) rather than service-to-service network integration.

## Test Scenarios

### Scenario 1: Add Expense → Budget Recalculation → Notification (Units 2 + 3)
- **Description**: Verifies the call-site orchestration in `AddEditExpenseController.save()` correctly chains ExpenseService → BudgetService.recalculate → evaluateThresholds → NotificationService, exactly once per threshold per month.
- **Setup**: Fresh Isar test instance; seed a combined-scope Budget with `notify50 = true`.
- **Test Steps**:
  1. Pump `AddEditExpenseScreen` with a `ProviderScope` overriding the Isar provider to the test instance.
  2. Enter an amount that crosses 50% of the budget, select a category, tap Save.
  3. Assert `NotificationService.notifyThresholdCrossed` was invoked once (mock/spy the plugin call, since `flutter_local_notifications` requires a device for real dispatch).
  4. Repeat an edit that keeps spend above 50% — assert no second notification (BR-14).
- **Expected Results**: Notification fires exactly once for the 50% threshold; a second save that keeps spend above 50% does not re-fire it.
- **Cleanup**: Close and delete the test Isar instance.

### Scenario 2: Onboarding → Dashboard (Units 2 + 4)
- **Description**: Verifies `SettingsService.completeOnboarding` (Unit 2) correctly seeds data that `DashboardController` (Unit 4) can immediately render without error.
- **Setup**: Fresh Isar test instance, `onboardingComplete = false`.
- **Test Steps**: Pump the app from `/onboarding`, complete the wizard with a budget amount, verify redirect to `/`, then verify `DashboardController.load()` completes without error and shows the just-configured budget.
- **Expected Results**: Dashboard shows the correct budget amount and ₹0 spent; no "no budget configured" prompt appears.

### Scenario 3: Dashboard/Reports Consistency (Units 4 + 5)
- **Description**: Verifies Unit 5's `ReportService.categoryAnalysis()`/`monthlySpending()` (now consumed by Dashboard) produce figures consistent with the Reports screen's own tabs for the same period.
- **Setup**: Seed several expenses across 2+ categories and 2+ months.
- **Test Steps**: Load Dashboard, capture its category breakdown and monthly trend values; navigate to Reports, capture the Category and Monthly tabs' values for the same period.
- **Expected Results**: Values are identical (both consume the same `ReportService` methods) — this is a regression guard against Dashboard drifting from Reports if either is edited independently in the future.

### Scenario 4: Backup → Restore Preserves Cross-Unit Consistency (Unit 6)
- **Description**: Beyond the unit-test-level round-trip already covered in `backup_service_test.dart`, verify that after a restore, Unit 3's `BudgetService.evaluateThresholds` and Unit 5's `ReportService` produce the same results against the restored data as they did against the original (i.e., restore doesn't silently corrupt `firedThresholds` or category associations in a way that only surfaces through business-logic behavior, not raw field equality).
- **Setup**: Seed data with at least one already-fired threshold; back up; restore into a fresh instance.
- **Test Steps**: Compare `evaluateThresholds` behavior (should NOT re-fire the already-fired threshold) and `ReportService.categoryAnalysis` totals before and after restore.
- **Expected Results**: Identical business-logic behavior pre- and post-restore, not just identical raw data.

## Setup Integration Test Environment

### 1. No external services to start
This app has no backend, so there's no `docker-compose`/service startup step. The only "environment" is:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Widget Test Harness
Integration tests should use `flutter_test`'s `testWidgets()` with a `ProviderScope` that overrides `isarInstanceProvider` to point at a per-test temporary Isar instance (reusing the `openTestIsar()` helper from `test/helpers/isar_test_helper.dart`).

## Run Integration Tests

### 1. Execute Integration Test Suite
```bash
flutter test integration_test/
# or, if kept alongside unit tests:
flutter test test/integration/
```
**Note**: No integration test files currently exist in this repository — this document specifies the scenarios to write. See "Known Gaps" in unit-test-instructions.md.

### 2. Verify Service Interactions
Cross-reference each scenario's expected results against the specific BR-numbered business rules it exercises (BR-14 for Scenario 1, BR-9 for Scenario 2, BR-24 for Scenario 3, BR-29 for Scenario 4).

### 3. Cleanup
Each test's `tearDown` should close and delete its temporary Isar instance, consistent with the pattern already established in unit tests.
