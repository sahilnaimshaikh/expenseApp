# Code Summary — Unit 3: Budgeting & Notifications

## Application Code Created/Modified

### Modified (Unit 1 files, extended not duplicated)
- `lib/features/core_data/domain/models/budget.dart` — added `firedThresholds: List<int>` field
- `lib/features/core_data/domain/budget_service.dart` — added `recalculate`, `getBudgetStatus`, `evaluateThresholds`, `updateNotificationThresholds`, `_sumExpenses`; constructor now also takes `ExpenseRepository`
- `lib/features/core_data/domain/core_data_domain_providers.dart` — `budgetServiceProvider` updated for the new constructor signature

### New
- `lib/features/core_data/domain/budget_status.dart` — `BudgetStatus`, `ThresholdCrossing`
- `lib/features/notifications/domain/notification_service.dart` — `NotificationService`
- `lib/features/notifications/domain/notification_providers.dart` — `notificationServiceProvider`, `notificationInitProvider`
- `lib/features/budgeting/presentation/budget_controller.dart` — `BudgetController`
- `lib/features/budgeting/presentation/budget_screen.dart` — `BudgetScreen`

### Extended (Unit 2 files)
- `lib/features/expense_management/presentation/add_edit_expense_controller.dart` — `save()` now calls `_recalculateAndNotify()` after a successful add/edit
- `lib/features/expense_management/presentation/expense_list_controller.dart` — `deleteOne()`/`deleteSelected()` now recalculate affected budgets (no notification, per BR-16)
- `lib/app_router.dart` — added `/budget` route
- `lib/main.dart` — added `notificationInitProvider` watch at app root

## Tests Created
- `test/features/core_data/domain/budget_service_threshold_test.dart` — BR-14 (fire-once), BR-15 (disabled thresholds), BR-17 (divide-by-zero), BR-19 (combined vs per-ledger) example tests, plus a glados PBT for the percentage-calculation invariant
- Fixed 2 pre-existing test files (`budget_service_test.dart`, `settings_service_test.dart`) to match `BudgetService`'s new 2-argument constructor

## Design Notes
- `AddEditExpenseController._recalculateAndNotify` and `ExpenseListController._recalculateAfterRemoval` both wrap their budget/notification calls in try/catch — a failure here never rolls back or blocks the already-successful expense mutation (fail-safe pattern from nfr-design-patterns.md).
- Both scopes (the expense's own ledger scope AND `LedgerScope.combined`) are always recalculated/evaluated together, since a single expense can affect both a per-ledger budget and a combined budget simultaneously (per requirements.md FR-3.2's "both" mode).

## Known Limitation
Same as prior units — no local Flutter/Dart SDK to compile/run. The `Decimal.parse(expense.amount.toString())` conversion in `_sumExpenses` should be reviewed once the SDK is available: converting a `double` to `String` then to `Decimal` is a reasonable way to avoid re-introducing float imprecision from the `double` itself, but its correctness depends on Dart's default `double.toString()` not silently rounding — flagged for verification during Build and Test.
