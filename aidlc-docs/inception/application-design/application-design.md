# Application Design — Expense Tracker (Consolidated)

This document consolidates the Application Design stage artifacts. See individual files for full detail:
- [components.md](components.md) — component definitions and responsibilities
- [component-methods.md](component-methods.md) — method signatures
- [services.md](services.md) — service orchestration patterns
- [component-dependency.md](component-dependency.md) — dependency matrix and data flows

## Architecture Style

Hybrid layered architecture: **Data → Domain → Presentation**, with capability-based grouping inside the Domain layer. Decision rationale and all 6 design decisions are recorded in [application-design-plan.md](../plans/application-design-plan.md).

## Layer Summary

### Data Layer (4 components)
Thin repositories, one per Isar collection: ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository. CRUD + basic queries only — no aggregation or business rules.

### Domain Layer (8 services)
One service per business capability: ExpenseService, CategoryService, BudgetService, ReportService, NotificationService, BackupService, ExportService, SettingsService. Domain services do not call each other to trigger cross-capability side effects (the key architectural decision — see below); the only exception is ReportService's read-only call into BudgetService.

### Presentation Layer (Riverpod)
One controller family per screen/capability, orchestrating one or more domain services. Controllers hold simple orchestration logic; all business rules live in the Domain layer.

## Key Architectural Decision: Orchestration at the Call Site

Because Notifications only fire from Budget threshold events, the natural instinct is a direct `BudgetService → NotificationService` dependency. Instead, this design puts that orchestration in the **presentation-layer controller** (e.g., `AddEditExpenseController`), which calls `ExpenseService.addExpense()` → `BudgetService.recalculate()` → `BudgetService.evaluateThresholds()` → `NotificationService.notifyThresholdCrossed()` in sequence.

**Why this matters for later stages**:
- BudgetService's threshold-evaluation logic (including the "fire at most once per month" business rule from stories.md US-12) can be unit- and property-tested with zero notification mocking.
- NotificationService remains a trivial, side-effect-only wrapper with no business logic to test.
- This pattern will recur for Backup/Export triggers and onboarding sequencing — Functional Design should preserve it rather than pulling orchestration logic down into domain services.

## Traceability to Requirements and Stories

Every domain service and its methods trace to specific FR/US identifiers (see [component-methods.md](component-methods.md) for the full mapping). No new capabilities were introduced beyond what requirements.md and stories.md already specify — Application Design only established *how* those capabilities are organized into components, not *what* they do.

## Open Items Carried Forward to Functional Design

These were flagged during User Stories and remain open, to be resolved per-unit in Functional Design:
1. Custom category deletion/reassignment policy (`CategoryService.deleteCategory`, stories.md US-06).
2. Backup retention/pruning policy specifics (`BackupService.pruneOldBackups`, stories.md US-20.5).
3. Whether export respects active list filters or always exports all data (`ExportService`, stories.md US-21.2).
4. Onboarding "skip budget for now" behavior (`SettingsService.completeOnboarding`, stories.md US-01.3).
5. Mechanism for triggering the automatic nightly backup on Android (platform scheduler choice) — affects `BackupService.runScheduledBackup`, to be resolved in NFR Design.

## Extension Compliance Note (Application Design stage)

- **Security Baseline**: Not yet applicable at this design-only stage beyond the general separation-of-concerns principle (SECURITY-11), which this layered architecture satisfies by isolating data access from business logic. Concrete rule-by-rule compliance (encryption, error handling, etc.) will be assessed in NFR Requirements/Design per component.
- **Resiliency Baseline**: RESILIENCY-01 (criticality) is implicitly addressed — BudgetService and BackupService are the most business-critical components (financial data integrity), which will carry through to NFR Design's data-integrity/crash-safety treatment.
- **Property-Based Testing**: The component/service split directly supports PBT-01 (property identification) — BudgetService (threshold math, recalculation), ReportService (aggregation), and ExportService (round-trip export/import) are the prime PBT candidates and are now cleanly isolated from UI and notification side effects.
