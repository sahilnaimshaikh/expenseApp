# Unit of Work — Expense Tracker

**Type**: Monolith (single Flutter app). Units below are **logical development groupings** ("Unit of Work" per units-generation.md terminology) that sequence the per-unit CONSTRUCTION loop (Functional Design → NFR Requirements → NFR Design → Code Generation), not independently deployable services.

**Decomposition approach**: 7 units, approved as proposed (see [unit-of-work-plan.md](../plans/unit-of-work-plan.md) Q1).

**Code organization**: Feature-first — `lib/features/{feature}/{data,domain,presentation}/` (Q3). Each unit maps to one or more top-level feature folders.

**Boundary strictness**: Strict at the service-interface level (Q2) — a later unit may call an earlier unit's public domain-service methods, but never reach into another unit's repository or private implementation details.

**Build approach**: Solo/sequential (Q4) — each unit fully completes Functional Design through Code Generation before the next unit begins, per execution-plan.md's per-unit loop.

**Technical constraints**: Uniform across all units — 100% offline, 500,000+ record scale, 60 FPS, 2s launch (Q5). No per-unit technical differentiation.

---

## Unit 1: Core Data & Categories

**Responsibility**: Establish the Isar database, all four repositories, and category management — the foundation every other unit depends on.

**Components** (from [components.md](components.md)):
- ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository (Data layer)
- CategoryService (Domain layer)
- `BudgetService.setBudgetAmount()` only (a simple upsert; full BudgetService ships in Unit 3 — see Cross-Unit Coordination Note in unit-of-work-plan.md)

**Feature folder**: `lib/features/core_data/`, `lib/features/categories/`

**Stories covered**: US-06 (default categories portion only; custom category icon/color picker also lands here since it's pure category CRUD)

**Rationale**: Every other unit reads/writes expenses, budgets, categories, or settings. This must exist first.

---

## Unit 2: Onboarding & Expense Management

**Responsibility**: First-launch onboarding, and full expense CRUD (add/edit/delete/list).

**Components**:
- ExpenseService (Domain layer)
- SettingsService — onboarding portion (`completeOnboarding`, `isOnboardingComplete`)
- AddEditExpenseController, ExpenseListController (Presentation layer, partial — search/filter/sort UI wiring deferred to Unit 5)

**Feature folder**: `lib/features/onboarding/`, `lib/features/expense_management/`

**Stories covered**: US-01, US-02, US-03, US-04, US-05

**Depends on**: Unit 1 (repositories, CategoryService for category selection, `BudgetService.setBudgetAmount()` for onboarding's initial budget).

**Rationale**: Expense CRUD is the app's core daily-use loop and has no dependency on budgeting logic itself (only calls the simple `setBudgetAmount` during onboarding, and will call full BudgetService starting in Unit 3's integration point — see US-02 acceptance criteria on threshold notifications, which activates once Unit 3 exists).

---

## Unit 3: Budgeting & Notifications

**Responsibility**: Full budget calculation (combined/per-ledger), threshold evaluation with the "fire once per month" rule, and local notification dispatch.

**Components**:
- BudgetService — full scope (`getBudgetStatus`, `evaluateThresholds`, `recalculate`)
- NotificationService (Domain layer)
- BudgetController (Presentation layer)
- Extends AddEditExpenseController from Unit 2 to add the full orchestration sequence (save → recalculate → evaluateThresholds → notify), per [services.md](services.md)'s call-site orchestration pattern

**Feature folder**: `lib/features/budgeting/`, `lib/features/notifications/`

**Stories covered**: US-11, US-12, US-13 (core display portion)

**Depends on**: Unit 1 (BudgetRepository, ExpenseRepository), Unit 2 (AddEditExpenseController, whose orchestration this unit extends).

**Rationale**: Budget math and notifications are tightly coupled business rules (per the Application Design Q5 decision) and are best designed/built together as one unit, immediately after basic expense CRUD exists to recalculate against.

---

## Unit 4: Dashboard

**Responsibility**: The financial-overview screen aggregating Budget, Expense, and Report data.

**Components**:
- DashboardController (Presentation layer)

**Feature folder**: `lib/features/dashboard/`

**Stories covered**: US-10

**Depends on**: Unit 1, Unit 2, Unit 3 (reads budget status and recent expenses), and reads basic aggregation that Unit 5's ReportService will later extend (Dashboard's category breakdown chart can initially use a minimal aggregation and be wired to full ReportService once Unit 5 completes — flagged for Functional Design to confirm sequencing).

**Rationale**: Dashboard is a pure aggregator with no business logic of its own — it must come after the units producing the data it displays.

---

## Unit 5: Search, Filter, Sort & Reporting

**Responsibility**: Expense search/filter/sort, and all 6 report types.

**Components**:
- `ExpenseService` query methods (`searchExpenses`, `filterAndSort`) — extends Unit 2's ExpenseService
- ReportService (Domain layer)
- ExpenseListController extensions (search/filter/sort UI), ReportsController (Presentation layer)

**Feature folder**: `lib/features/search_filter/`, `lib/features/reporting/`

**Stories covered**: US-07, US-08, US-09, US-14, US-15, US-16, US-17, US-18, US-19, US-13 (budget history portion)

**Depends on**: Unit 1 (ExpenseRepository), Unit 3 (BudgetService, for budget utilization report US-19).

**Rationale**: Reporting/analytics is the PRD's "Phase 2 – Analytics" and naturally depends on there being expense and budget data/logic to aggregate.

---

## Unit 6: Backup, Export & Settings

**Responsibility**: Manual/automatic backup & restore, CSV/Excel/JSON export, and ongoing app settings (theme, currency, notification preferences).

**Components**:
- BackupService, ExportService (Domain layer)
- SettingsService — ongoing settings portion (`updateTheme`, `updateCurrency`, `updateNotificationPreferences`)
- BackupExportController, SettingsController (Presentation layer)

**Feature folder**: `lib/features/backup_export/`, `lib/features/settings/`

**Stories covered**: US-20, US-21, US-22

**Depends on**: Unit 1 (all repositories, for backup payload assembly), Unit 2 (ExpenseService, for export data source).

**Rationale**: Backup/Export/Settings is the PRD's "Phase 3 – Productivity" scope and is naturally last among functional units since it operates over data produced by all prior units.

---

## Unit 7: Premium Polish

**Responsibility**: Cross-cutting UI/UX refinement — animations, Material 3 polish, accessibility.

**Components**: No new components; applies to all Presentation-layer controllers/widgets from Units 1-6.

**Feature folder**: Cross-cutting — touches `lib/features/**/presentation/` across all prior folders; no new top-level folder.

**Stories covered**: US-23, US-24

**Depends on**: All prior units (it polishes their UI).

**Rationale**: Matches PRD "Phase 4 – Premium Experience" — polish only makes sense once the functional screens it's polishing already exist.

## Code Organization Strategy Summary

```
lib/
  features/
    core_data/          (Unit 1 - shared Isar setup, no own screens)
    categories/          (Unit 1)
    onboarding/           (Unit 2)
    expense_management/  (Unit 2, extended by Unit 5)
    budgeting/            (Unit 3)
    notifications/        (Unit 3)
    dashboard/            (Unit 4)
    search_filter/        (Unit 5)
    reporting/            (Unit 5)
    backup_export/        (Unit 6)
    settings/              (Unit 6)
  # Unit 7 (Premium Polish) has no dedicated folder - it refines presentation/
  # subfolders across all features above.
  each feature/
    data/        (repositories, if owned by this feature)
    domain/      (services, models)
    presentation/ (Riverpod controllers, screens, widgets)
```
