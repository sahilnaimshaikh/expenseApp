# Code Summary — Unit 2: Onboarding & Expense Management

## Application Code Created

### Domain (`lib/features/expense_management/domain/`, `lib/features/onboarding/domain/`)
- `expense_input.dart` — `ExpenseInput` DTO
- `expense_service.dart` — `ExpenseService` (addExpense, editExpense, deleteExpense, deleteMany, listExpenses), `ExpenseValidationException`
- `expense_providers.dart` — `expenseServiceProvider`
- `onboarding_input.dart` — `OnboardingInput` DTO
- `settings_service.dart` — `SettingsService` (onboarding portion: completeOnboarding, isOnboardingComplete)
- `onboarding_providers.dart` — `settingsServiceProvider`

### Presentation (`lib/features/expense_management/presentation/`, `lib/features/onboarding/presentation/`)
- `onboarding_controller.dart` / `onboarding_screen.dart`
- `add_edit_expense_controller.dart` / `add_edit_expense_screen.dart`
- `expense_list_controller.dart` / `expense_list_screen.dart`

### App-Level
- `lib/app_router.dart` — GoRouter instance with onboarding-redirect guard, routes for `/onboarding`, `/`, `/expense/add`, `/expense/edit/:id`
- `lib/main.dart` — updated to use `MaterialApp.router` with the new router
- `lib/features/categories/domain/category_providers.dart` — added `allCategoriesProvider` (read-only category list for pickers)

## Tests Created
- `test/features/expense_management/domain/expense_service_test.dart` — BR-10/11/12/13 example tests + glados PBT (amount positivity invariant)
- `test/features/onboarding/domain/settings_service_test.dart` — BR-9 (skippable budget) and onboarding-flow example tests

## Design Notes Carried Forward
- `AddEditExpenseController.save()` is documented as an **extension seam** — Unit 3 extends (not duplicates) this method to add budget recalculation and notification dispatch, per Application Design's Q5 call-site-orchestration decision.
- `SettingsService` is documented as extended (not duplicated) by Unit 6, which adds the ongoing-settings methods (updateTheme/updateCurrency/updateNotificationPreferences).
- `lib/app_router.dart` is the single shared GoRouter instance; Units 3-7 add routes to this file rather than creating new router instances.

## Known Limitation
Same as Unit 1: no local Flutter/Dart SDK available in this session to run `flutter analyze`/`flutter test`/`build_runner`. Widget-level tests (pump/tap simulation) were not written for the three new screens in this pass — only controller/service-layer logic is unit-tested. This is flagged for the Build and Test stage as a gap to close with `flutter_test`'s widget testing tools once the SDK is available.
