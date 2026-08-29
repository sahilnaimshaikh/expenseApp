# Application Design Plan — Expense Tracker

## Context Analysis

From [requirements.md](../requirements/requirements.md) and [stories.md](../user-stories/stories.md), the following business capabilities/functional areas were identified:

1. **Expense Management** — CRUD on expenses, tags, custom categories (US-02 to US-06)
2. **Ledger Views** — Personal/Home/Combined scoping used across budgets, dashboard, reports (FR-2)
3. **Budgeting** — combined or per-ledger monthly budgets, percentage calculation, threshold evaluation with silent-recalculation rule (US-11, US-12, US-13)
4. **Search/Filter/Sort** — over the expense list (US-07, US-08, US-09)
5. **Reporting/Analytics** — 6 report types aggregating expense data (US-14 to US-19)
6. **Dashboard** — aggregates data from Budgeting, Ledger Views, Reporting, recent expenses (US-10)
7. **Notifications** — local notifications fired by Budgeting threshold events (US-12, FR-7)
8. **Backup & Export** — manual/automatic backup, restore, CSV/Excel/JSON export (US-20, US-21)
9. **Onboarding & Settings** — first-launch wizard, theme/currency/notification preferences (US-01, US-22)

**Design scope**: New system, all components greenfield. Complexity: Moderate — no distributed system concerns (offline, single device), but meaningful business logic (budget/threshold rules, aggregation) that benefits from clear separation from UI and from the Isar persistence layer, especially given the enabled Property-Based Testing extension (PBT-01 requires property identification during Functional Design, which needs stable component boundaries first).

## Execution Checklist

- [x] Step 1: Answer context-appropriate questions below (component organization, service boundaries, dependency/communication patterns, design pattern)
- [x] Step 2: Analyze answers for ambiguity; issue follow-ups if needed
- [x] Step 3: Generate `components.md`
- [x] Step 4: Generate `component-methods.md`
- [x] Step 5: Generate `services.md`
- [x] Step 6: Generate `component-dependency.md`
- [x] Step 7: Generate consolidated `application-design.md`
- [ ] Step 8: Present for review and approval

## Decisions Recorded (user delegated: "Do what you think is best")

The user delegated all 6 questions. Decisions made directly, with rationale:

- **Q1 → C) Hybrid**: layered architecture (data / domain / presentation) as the top-level structure, capability-based sub-grouping within the domain layer. Chosen because it's the standard, well-understood Flutter architecture pattern, scales cleanly as features grow, and keeps persistence (Isar) decoupled from business logic — important for testability under the enabled Property-Based Testing extension.
- **Q2 → A) One service per capability**: ExpenseService, BudgetService, NotificationService, ReportService, CategoryService, SettingsService (plus Backup/Export per Q6). Chosen over merging Budget+Notification because Q5 already establishes a decoupled, orchestration-based relationship between them (no direct service-to-service dependency needed), so keeping them separate maximizes testability (PBT can exercise BudgetService's math in total isolation from notification side-effects) and keeps single responsibility clean for a project this size.
- **Q3 → A) One repository per Isar collection, thin CRUD**: ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository — with all aggregation/business logic in services. Standard clean-architecture separation; keeps repositories trivially testable/mockable.
- **Q4 → B) Providers allow simple orchestration, delegate business rules to services**: pragmatic middle ground — full purity (A) is overly rigid for a Riverpod app, "no rule" (C) invites inconsistency across a solo-maintained codebase.
- **Q5 → C) Call-site orchestration**: the Add/Edit/Delete Expense flow (a presentation-layer controller) orchestrates save → BudgetService.recalculate → BudgetService.evaluateThresholds → NotificationService.notify. Chosen over direct Budget→Notification dependency (A, adds coupling) or an event bus (B, unnecessary infrastructure for a single-device app with no concurrent event sources).
- **Q6 → B) Two separate components**: BackupService (backup/restore, including the automatic nightly job) and ExportService (CSV/Excel/JSON, on-demand only). Chosen because they have genuinely different triggers (scheduled vs. user-initiated) and different consumers (restore reloads into Isar; export is one-way and human-readable) — conflating them would blur two distinct responsibilities.

---

## Clarifying Questions

### Question 1: Component Organization Strategy
How should components be organized/grouped?

A) By business capability (one component group per capability above: Expense Management, Budgeting, Reporting, Notifications, Backup/Export, Onboarding/Settings) — mirrors the Feature-Based story breakdown already used in stories.md

B) By architectural layer first, then capability within each layer (e.g., all repositories together, all business-logic services together, all Riverpod providers together) — classic layered architecture

C) Hybrid: layered architecture (data / domain / presentation) as the top-level structure, with capability-based sub-grouping inside the domain layer

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 2: Service Layer Granularity
Should each business capability have its own dedicated service class, or should some be combined?

A) One service per capability (ExpenseService, BudgetService, NotificationService, BackupService, ReportService, CategoryService, SettingsService) — maximum separation

B) Combine tightly-coupled capabilities into fewer services (e.g., Budget + Notification into one BudgetService since notifications only fire from budget threshold events; Reporting folded into a shared QueryService alongside Search/Filter/Sort since both just query/aggregate expense data)

C) Minimal services — most logic lives directly in Riverpod providers/notifiers calling repositories, with only genuinely complex cross-cutting logic (budget threshold evaluation) pulled into a dedicated service

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 3: Repository/Data-Access Pattern
How should Isar data access be structured?

A) One repository per Isar collection (ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository), each exposing CRUD + basic query methods; higher-level aggregation (reports, budget %) happens in services that consume repositories

B) Repositories expose only raw CRUD; ALL querying/filtering/aggregation logic (including simple ones) happens exclusively in services, keeping repositories as thin as possible

C) No repository abstraction — services/providers call Isar collections directly (fewer layers, less boilerplate, but tighter coupling to Isar)

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 4: State Management / Presentation Wiring
How should Riverpod fit into the component picture?

A) Riverpod providers are a thin presentation-layer concern only — they call into services/repositories and expose state to widgets, with zero business logic of their own

B) Riverpod providers can contain simple orchestration logic (e.g., combining two service calls, basic derived state) but delegate all business rules (budget math, threshold checks) to services

C) No strict rule — allow logic in providers where convenient; decide case-by-case during Functional Design

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 5: Cross-Component Dependency Direction
Given Notifications only fire from Budget threshold events (per US-12's business rule), and Backup/Export needs read access to Expense/Budget/Category/Settings data, how should these dependencies be structured?

A) Budgeting depends on/calls Notification Service directly (Budget → Notification) when it detects a new threshold crossing

B) Budgeting emits a domain event/signal that Notification Service listens for, avoiding a direct call dependency (event-driven, more decoupled, slightly more infrastructure)

C) Notification triggering is a thin wrapper called explicitly by the Expense/Budget flow at the same call site that saves the expense (i.e., the caller — e.g., an Add Expense use-case/provider — orchestrates: save expense → recalculate budget → check threshold → call notification service), rather than Budget Service depending on Notification Service internally

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 6: Backup/Export Component Scope
Should Backup and Export be one component or two?

A) One component (BackupExportService) handling both backup/restore (ZIP of DB+settings+categories) and data export (CSV/Excel/JSON) since they're both "get data out of the app" operations

B) Two separate components — BackupService (backup/restore, including the automatic nightly job) and ExportService (CSV/Excel/JSON, user-initiated only) since they have different triggers (scheduled vs. on-demand) and different consumers (restore = reload into Isar; export = one-way, human-readable)

X) Other (please describe after [Answer]: tag below)

[Answer]:
