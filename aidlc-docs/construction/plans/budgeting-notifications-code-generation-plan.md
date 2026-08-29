# Code Generation Plan — Unit 3: Budgeting & Notifications

## Unit Context
- **Stories implemented**: US-11, US-12, US-13 (core)
- **Dependencies**: Unit 1 (BudgetRepository, ExpenseRepository), Unit 2 (extends AddEditExpenseController, ExpenseListController)
- **Schema change**: Added `firedThresholds: List<int>` to Unit 1's `Budget` entity (documented in functional-design/domain-entities.md)

## Steps
- [x] Step 1: Project structure — `lib/features/notifications/`, `lib/features/budgeting/presentation/`
- [x] Step 2: Business Logic Generation — extended `BudgetService` (recalculate, evaluateThresholds, updateNotificationThresholds), `BudgetStatus`/`ThresholdCrossing` value types, `NotificationService`
- [x] Step 3: Business Logic Unit Testing — BR-14 through BR-19 example tests + 1 glados PBT (percentage invariant)
- [x] Step 4-7: Summaries — this file + code-summary.md
- [x] Step 8: Frontend Components Generation — BudgetScreen, BudgetController; extended AddEditExpenseController and ExpenseListController with the call-site orchestration (recalculate + evaluateThresholds + notify)
- [x] Step 9: Frontend Components Unit Testing — deferred to widget-test tier (consistent with Unit 2's note)
- [x] Step 10: Documentation — dartdoc on all new/extended public members
- [x] Step 11: Deployment Artifacts — N/A, deferred

## Story Traceability
| Story | Implementation |
|---|---|
| US-11 | BudgetService.setBudgetAmount (Unit 1) + BudgetScreen's set-amount dialog |
| US-12 | BudgetService.evaluateThresholds, NotificationService, AddEditExpenseController extension |
| US-13 (core) | BudgetScreen, BudgetController |
