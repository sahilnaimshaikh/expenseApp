# Components — Expense Tracker

**Architecture style**: Hybrid layered (Data / Domain / Presentation) with capability-based grouping inside the Domain layer (per [application-design-plan.md](../plans/application-design-plan.md) Q1).

## Data Layer

### ExpenseRepository
**Purpose**: CRUD and basic queries over the Isar `Expense` collection.
**Responsibilities**:
- Create, read, update, delete expense records.
- Provide basic filtered/sorted queries (by date range, category, expense type, payment method, amount range) as building blocks — aggregation logic lives in services, not here.

### BudgetRepository
**Purpose**: CRUD over the Isar `Budget` collection.
**Responsibilities**:
- Create/read/update monthly budget records (combined and per-ledger modes).
- Query budget records by month/year/ledger.

### CategoryRepository
**Purpose**: CRUD over the Isar `Category` collection.
**Responsibilities**:
- Create, read, update, delete categories (default-seeded + custom).
- Query categories by id/name.

### SettingsRepository
**Purpose**: CRUD over the Isar `Settings` collection (a effectively-singleton record).
**Responsibilities**:
- Read/write app settings: theme, currency, notification preferences, backup location.

## Domain Layer

### ExpenseService
**Purpose**: Business logic for expense lifecycle and querying/filtering/sorting.
**Responsibilities**:
- Validate and orchestrate create/edit/delete of expenses (via ExpenseRepository).
- Provide search (description/category/tags/payment method), filter (month/year/date range/category/type/payment method/amount range), and sort (newest/oldest/highest/lowest amount) over expenses.
- Notify BudgetService of expense changes that affect budget totals (via call-site orchestration — see [component-dependency.md](component-dependency.md)).

### CategoryService
**Purpose**: Business logic for category management.
**Responsibilities**:
- Manage default category seeding on first launch.
- Validate custom category creation (name uniqueness, icon/color assignment).
- Handle custom category deletion policy (reassignment/orphan handling — open design item from stories.md US-06, to be finalized in Functional Design).

### BudgetService
**Purpose**: Business logic for monthly budgets and threshold evaluation.
**Responsibilities**:
- Compute monthly spend, remaining amount, and percentage used (combined or per-ledger mode, per requirements.md FR-3.2).
- Evaluate configured notification thresholds (50/75/90/100%) against current spend.
- Implement the silent-recalculation business rule (stories.md US-12/Q6): thresholds fire at most once per month per threshold, regardless of how the crossing occurred (add/edit/delete).
- Handle month-rollover to start new budget periods (US-11).

### ReportService
**Purpose**: Business logic for all reporting/analytics views.
**Responsibilities**:
- Monthly spending totals, category analysis, Personal vs Home comparison, top spending categories, monthly comparison, budget utilization (stories.md US-14 to US-19).
- Consumes ExpenseRepository and BudgetService; performs all aggregation itself (repositories stay thin per Q3).

### NotificationService
**Purpose**: Wraps `flutter_local_notifications` to fire local notifications.
**Responsibilities**:
- Fire budget threshold-reached/exceeded notifications (triggered by call-site orchestration from the Expense flow, not by direct BudgetService dependency — see Q5 decision).
- Fire optional end-of-month summary notifications.
- No business logic of its own — purely a notification-dispatch wrapper.

### BackupService
**Purpose**: Business logic for backup and restore.
**Responsibilities**:
- Automatic silent nightly local backup (DB + settings + categories) to app-private storage (requirements.md FR-8.2).
- Manual on-demand backup to a ZIP archive at a user-chosen/app-designated location.
- Restore from a ZIP archive with fail-safe validation (reject corrupted archives without touching existing data — stories.md US-20).
- Backup retention/pruning policy for accumulated nightly backups (open item — finalized in Functional/NFR Design).

### ExportService
**Purpose**: Business logic for one-way data export.
**Responsibilities**:
- Export expense data to CSV, Excel, and JSON formats, on user request only (stories.md US-21).
- Handle export failure safely (no partially-written files).

### SettingsService
**Purpose**: Business logic for app-wide settings and onboarding.
**Responsibilities**:
- Apply theme/currency/notification-preference changes app-wide.
- Drive the first-launch onboarding flow (currency selection, initial budget creation) — coordinates CategoryService (seed defaults) and BudgetService (create initial budget).

## Presentation Layer (Riverpod)

### Providers/Notifiers (one family per screen/capability)
**Purpose**: Expose domain-layer state to widgets; hold UI state; perform simple orchestration only (per Q4 — business rules stay in services).
**Responsibilities** (representative, not exhaustive — finalized per-unit in Functional Design):
- `OnboardingController` — drives US-01 onboarding wizard, calls SettingsService/CategoryService/BudgetService.
- `AddEditExpenseController` — drives US-02/US-03, orchestrates ExpenseService.save → BudgetService.recalculate → BudgetService.evaluateThresholds → NotificationService.notify (the call-site orchestration from Q5).
- `ExpenseListController` — drives US-05/US-07/US-08/US-09 (list, search, filter, sort).
- `DashboardController` — drives US-10, aggregates data from BudgetService, ExpenseService, ReportService.
- `BudgetController` — drives US-11/US-12/US-13.
- `ReportsController` — drives US-14 to US-19, delegates to ReportService.
- `SettingsController` — drives US-22, delegates to SettingsService.
- `BackupExportController` — drives US-20/US-21, delegates to BackupService/ExportService.

## Component Summary Table

| Component | Layer | Capability |
|---|---|---|
| ExpenseRepository | Data | Expense Management |
| BudgetRepository | Data | Budgeting |
| CategoryRepository | Data | Expense Management |
| SettingsRepository | Data | Settings/Onboarding |
| ExpenseService | Domain | Expense Management, Search/Filter/Sort |
| CategoryService | Domain | Expense Management |
| BudgetService | Domain | Budgeting |
| ReportService | Domain | Reporting |
| NotificationService | Domain | Notifications |
| BackupService | Domain | Backup |
| ExportService | Domain | Export |
| SettingsService | Domain | Settings/Onboarding |
| (Riverpod Controllers) | Presentation | All screens |
