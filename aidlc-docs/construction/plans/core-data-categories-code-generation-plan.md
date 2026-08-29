# Code Generation Plan — Unit 1: Core Data & Categories

## Unit Context
- **Stories implemented**: US-06 (Manage Categories — Default + Custom)
- **Dependencies**: None (foundation unit)
- **Depended on by**: Units 2-6
- **Database entities owned**: Expense, Budget, Category, Settings (Isar collections)
- **Service boundaries**: ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository, CategoryService, `BudgetService.setBudgetAmount()` only

**Workspace root**: `/Users/admin/go/KOTAK-NEO/aidlc_demo` (per aidlc-state.md)
**Project structure**: Greenfield, monolith, feature-first (per unit-of-work.md) — Flutter standard: `lib/`, `test/`, `pubspec.yaml` at workspace root.

## Steps

- [x] Step 1: Project Structure Setup — `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart` skeleton, `lib/features/core_data/` and `lib/features/categories/` folder scaffolding, Isar codegen config
- [x] Step 2: Business Logic Generation — domain models (Expense, Budget, Category, Settings) with Isar annotations; CategoryService; BudgetService (Unit 1 slice); RepositoryException; LedgerScope/AppThemeMode/PaymentMethod/ExpenseType enums
- [x] Step 3: Business Logic Unit Testing — example-based tests for CategoryService business rules (BR-1, BR-2, BR-3, BR-4) and BudgetService (BR-7) + `glados`-based property tests for the identified PBT properties
- [x] Step 4: Business Logic Summary — markdown summary in `aidlc-docs/construction/core-data-categories/code/`
- [x] Step 5: Repository Layer Generation — ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository (Isar-backed, with indexes per tech-stack-decisions.md)
- [x] Step 6: Repository Layer Unit Testing — round-trip PBT + CRUD example tests per repository, using an isolated temp-directory Isar instance per test
- [x] Step 7: Repository Layer Summary — included in code summary
- [x] Step 8: Database Migration Scripts — N/A for Isar; documented in code summary (Isar's schema evolution approach)
- [x] Step 9: Documentation Generation — `README.md` updated (project overview, setup instructions, build note on missing `*.g.dart`), dartdoc comments on all public classes/methods
- [x] Step 10: Deployment Artifacts Generation — N/A at this unit; deferred to Build and Test stage after all units complete

## Story Traceability
| Step | Story |
|---|---|
| 1-2 (Category model + CategoryService) | US-06 |
| 5 (CategoryRepository) | US-06 |
| All steps | Foundation for US-01 through US-24 (no direct story ownership beyond US-06, but blocks all other units) |

**Note**: Per user instruction to proceed autonomously without stopping for approval, this plan is executed immediately following creation.
