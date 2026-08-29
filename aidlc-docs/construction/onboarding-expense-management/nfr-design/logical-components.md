# Logical Components — Unit 2: Onboarding & Expense Management

## GoRouter Provider
**Type**: Riverpod `Provider<GoRouter>`
**Responsibility**: Defines all app routes and the onboarding-redirect guard. Extended by every subsequent unit as new screens are added (Units 3-7 each add routes here rather than creating competing router instances).

## ExpenseService, SettingsService (extended)
`ExpenseService` (new in this unit) and `SettingsService`'s onboarding methods (new in this unit) — both plain Dart classes exposed via Riverpod `Provider`s, depending on Unit 1's repositories/CategoryService/BudgetService.

## Presentation Controllers
`OnboardingController`, `AddEditExpenseController`, `ExpenseListController` — Riverpod `Notifier`/`AsyncNotifier` classes as decided in tech-stack-decisions.md.
