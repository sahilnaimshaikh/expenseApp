# Services — Expense Tracker

Per [application-design-plan.md](../plans/application-design-plan.md) Q2 (one service per capability) and Q6 (Backup/Export split), the Domain layer defines 8 services. This document describes each service's orchestration role and interactions; method-level detail is in [component-methods.md](component-methods.md).

## ExpenseService
**Orchestration role**: The entry point for all expense CRUD and querying. Called directly by presentation-layer controllers (AddEditExpenseController, ExpenseListController). Does not call other services directly — the *caller* (a controller) orchestrates cross-service sequences (see Q5 decision and [component-dependency.md](component-dependency.md)).

## CategoryService
**Orchestration role**: Manages category lifecycle independently. Called by ExpenseService's consumers (for category selection) and by SettingsService during onboarding (`ensureDefaultsSeeded`).

## BudgetService
**Orchestration role**: The core business-rule engine for budgets. Exposes `recalculate` and `evaluateThresholds` as separate steps so the calling controller can sequence: save expense → recalculate → evaluate thresholds → (if crossed) call NotificationService. BudgetService itself never calls NotificationService — this is the Q5 decision to avoid a Budget→Notification service dependency, keeping BudgetService's business logic (especially the "fire once per month" rule) fully unit-testable and property-testable in isolation.

## ReportService
**Orchestration role**: A read-only aggregation service. Consumes ExpenseRepository (for raw data) and BudgetService (for utilization %) but produces no side effects — safe to call freely from any reporting screen.

## NotificationService
**Orchestration role**: A dispatch-only wrapper around `flutter_local_notifications`. Never initiates its own business logic — only reacts to being called by a controller (per Q5). Has no dependencies on other domain services.

## BackupService
**Orchestration role**: Owns both the scheduled automatic backup job and manual backup/restore. Reads from all four repositories (Expense, Budget, Category, Settings) to assemble a backup; writes back to all four on restore. Runs independently of user-facing controllers for the scheduled path (triggered by a platform-level scheduler, TBD in NFR Design), and via BackupExportController for the manual path.

## ExportService
**Orchestration role**: A read-only, one-way consumer of ExpenseRepository (and CategoryRepository, for human-readable category names in exports). Kept separate from BackupService (Q6) since it never writes back into the app's own data.

## SettingsService
**Orchestration role**: Coordinates the first-launch onboarding sequence — calls CategoryService.ensureDefaultsSeeded() and BudgetService.setBudgetAmount() as part of `completeOnboarding()`. Also owns ongoing settings (theme/currency/notifications) read/write via SettingsRepository.

## Cross-Service Orchestration Pattern (Q5)

No domain service calls another domain service to trigger a *side effect* in a different capability (e.g., BudgetService never calls NotificationService). Instead, the **presentation-layer controller** is the orchestrator for multi-step business flows. Example — Add Expense flow:

```
AddEditExpenseController.save(input):
  1. expense = ExpenseService.addExpense(input)
  2. status  = BudgetService.recalculate(month, year, expense.ledgerScope)
  3. crossings = BudgetService.evaluateThresholds(month, year, expense.ledgerScope)
  4. for each crossing in crossings:
       NotificationService.notifyThresholdCrossed(crossing)
```

This keeps each service independently testable (BudgetService's threshold math can be property-tested with zero notification mocking) while still delivering the end-to-end user-visible behavior described in stories.md US-02 and US-12.

**Exception — read-only composition is allowed**: ReportService is permitted to call BudgetService (for utilization %) because this is a pure read composition with no side effects, not a business-rule/orchestration dependency.
