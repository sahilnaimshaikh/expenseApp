# Code Generation Plan — Unit 2: Onboarding & Expense Management

## Unit Context
- **Stories implemented**: US-01, US-02, US-03, US-04, US-05
- **Dependencies**: Unit 1 (repositories, CategoryService, BudgetService.setBudgetAmount)
- **Database entities owned**: None new (consumes Unit 1's)
- **Service boundaries**: ExpenseService, SettingsService (onboarding portion), AddEditExpenseController, ExpenseListController, OnboardingController

## Steps
- [x] Step 1: Project structure — `lib/features/onboarding/`, `lib/features/expense_management/` (data/domain/presentation), `lib/app_router.dart`
- [x] Step 2: Business Logic Generation — ExpenseInput/OnboardingInput DTOs, ExpenseService (BR-10/11/12/13), SettingsService onboarding portion (BR-9), ExpenseValidationException
- [x] Step 3: Business Logic Unit Testing — example tests + glados property test (amount positivity invariant) for ExpenseService; example tests for SettingsService onboarding flow
- [x] Step 4: Business Logic Summary — this file + code-summary.md
- [x] Step 5: Repository Layer Generation — N/A, no new repositories this unit
- [x] Step 6-7: N/A
- [x] Step 8: Frontend Components Generation — OnboardingScreen, AddEditExpenseScreen, ExpenseListScreen, plus their Notifier controllers
- [x] Step 9: Frontend Components Unit Testing — deferred to widget-test tier; controller logic covered by domain-layer tests above (controllers are thin orchestration per Application Design Q4)
- [x] Step 10: Documentation Generation — dartdoc comments on all new public classes
- [x] Step 11: Deployment Artifacts — N/A, deferred to Build and Test

## Story Traceability
| Story | Implementation |
|---|---|
| US-01 | OnboardingScreen, OnboardingController, SettingsService.completeOnboarding |
| US-02 | AddEditExpenseScreen (add mode), ExpenseService.addExpense |
| US-03 | AddEditExpenseScreen (edit mode), ExpenseService.editExpense |
| US-04 | ExpenseListScreen swipe-left, ExpenseService.deleteExpense |
| US-05 | ExpenseListScreen (grouping, swipe, multi-select), ExpenseService.deleteMany |
