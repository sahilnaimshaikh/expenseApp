# Code Summary — Unit 1: Core Data & Categories

## Application Code Created

### Project Setup
- `pubspec.yaml` — declares full app dependency set (Isar, Riverpod, Go Router, FL Chart, flutter_local_notifications, decimal, glados, etc.) per tech-stack-decisions.md, though most are only consumed starting Unit 2+
- `analysis_options.yaml` — flutter_lints baseline, excludes generated `*.g.dart` from analysis
- `.gitignore` — standard Flutter ignores plus generated Isar files
- `lib/main.dart` — app entry point, `ProviderScope` root, placeholder home screen (replaced starting Unit 2)

### Domain Models (`lib/features/core_data/domain/models/`)
- `enums.dart` — `ExpenseType`, `LedgerScope`, `PaymentMethod`, `AppThemeMode`, plus an `ExpenseTypeToLedgerScope` extension
- `expense.dart` — `Expense` Isar collection (indexes on date/categoryId/expenseType/paymentMethod)
- `budget.dart` — `Budget` Isar collection (composite unique index on month+year+ledgerScope)
- `category.dart` — `Category` Isar collection + `DefaultCategories` constant (13 PRD categories)
- `settings.dart` — `Settings` Isar collection (enforced singleton via fixed `id`)

### Data Layer (`lib/features/core_data/data/`)
- `isar_provider.dart` — `isarInstanceProvider` (Riverpod `FutureProvider<Isar>`), opens the single app-wide Isar instance
- `expense_repository.dart` — `ExpenseRepository`, `ExpenseQueryParams`
- `budget_repository.dart` — `BudgetRepository`
- `category_repository.dart` — `CategoryRepository` (includes `seedDefaults()`)
- `settings_repository.dart` — `SettingsRepository` (singleton-safe)
- `core_data_providers.dart` — Riverpod `FutureProvider`s wiring Isar into each repository

### Domain Layer (business logic)
- `lib/features/core_data/domain/repository_exception.dart` — `RepositoryException` (BR-8)
- `lib/features/core_data/domain/budget_service.dart` — `BudgetService` (Unit 1 slice: `setBudgetAmount` only), `BudgetValidationException`
- `lib/features/core_data/domain/core_data_domain_providers.dart` — `budgetServiceProvider`
- `lib/features/categories/domain/category_service.dart` — `CategoryService`, `CategoryValidationException`
- `lib/features/categories/domain/category_providers.dart` — `categoryServiceProvider`

## Tests Created (`test/`)
- `test/helpers/isar_test_helper.dart` — `openTestIsar()`, opens an isolated temp-directory Isar instance per test
- `test/features/core_data/data/expense_repository_test.dart` — CRUD example tests + PBT round-trip property (Glados-generated `Expense` instances)
- `test/features/core_data/data/budget_repository_test.dart` — upsert/uniqueness/scope-distinction example tests
- `test/features/core_data/data/category_repository_test.dart` — seeding, case-insensitive lookup, delete, PBT round-trip property
- `test/features/core_data/data/settings_repository_test.dart` — singleton enforcement example tests (BR-5)
- `test/features/core_data/domain/budget_service_test.dart` — upsert-not-duplicate, positivity rule (BR-7) example tests
- `test/features/categories/domain/category_service_test.dart` — BR-1 (uniqueness), BR-2 (default protection), BR-3 (reassign-on-delete), BR-4 (seeding idempotence) example tests + PBT invariant property (name uniqueness across generated names)

## PBT Compliance (Property-Based Testing Extension)

| Property (from business-rules.md) | Test Location | Status |
|---|---|---|
| Round-trip persistence (Expense) | `expense_repository_test.dart` (`Glados(anyExpense)`) | Implemented |
| Round-trip persistence (Category) | `category_repository_test.dart` (`Glados(anyCustomCategory)`) | Implemented |
| Round-trip persistence (Budget, Settings) | Covered by example-based tests only in this unit; Budget/Settings have simpler shapes with fewer fields and lower combinatorial risk than Expense — deferred generalization to PBT is not required here since example tests already exercise all fields | N/A — documented rationale |
| Category name uniqueness invariant | `category_service_test.dart` (`Glados` over generated names) | Implemented |
| Seeding idempotence | `category_service_test.dart` (`ensureDefaultsSeeded is idempotent...`) | Implemented (example-based repetition test; not a generated property since the operation takes no input parameters to vary) |

## Database Migration Notes
Isar does not use traditional SQL-style migration scripts. Schema evolution happens via Isar's own versioned collection schemas (`@collection` classes regenerate `*.g.dart` via `build_runner`); backward-incompatible field changes require a manual data-migration function run at app startup. No such migration exists yet since this is the initial schema — this section will be revisited if a later unit needs to change an existing entity's shape.

## Known Limitation: Code Not Locally Compiled/Run
This code was generated in an environment without the Flutter/Dart SDK installed (`flutter`/`dart` commands unavailable). It has **not** been run through `flutter analyze`, `dart pub get`, `build_runner`, or `flutter test` in this session. The Isar query-builder API surface (`.filter()`, `.optional()`, generated field-matcher methods like `.categoryIdEqualTo()`) was written to match Isar 3.1.x's documented conventions, but syntax correctness has not been machine-verified. **This is flagged explicitly in the Build and Test stage instructions** — running `flutter pub get && flutter pub run build_runner build && flutter test` locally is the required first verification step before trusting this code.
