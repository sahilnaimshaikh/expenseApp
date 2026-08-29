# Component Dependency — Expense Tracker

## Dependency Matrix

| Component | Depends On |
|---|---|
| ExpenseRepository | Isar (Expense collection) |
| BudgetRepository | Isar (Budget collection) |
| CategoryRepository | Isar (Category collection) |
| SettingsRepository | Isar (Settings collection) |
| ExpenseService | ExpenseRepository |
| CategoryService | CategoryRepository |
| BudgetService | BudgetRepository, ExpenseRepository (to sum spend) |
| ReportService | ExpenseRepository, BudgetService (read-only, for utilization %) |
| NotificationService | flutter_local_notifications (platform plugin) — no domain service dependencies |
| BackupService | ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository, File System |
| ExportService | ExpenseRepository, CategoryRepository, File System |
| SettingsService | SettingsRepository, CategoryService, BudgetService |
| AddEditExpenseController | ExpenseService, BudgetService, NotificationService (orchestrates all three per Q5) |
| ExpenseListController | ExpenseService |
| DashboardController | BudgetService, ExpenseService, ReportService |
| BudgetController | BudgetService |
| ReportsController | ReportService |
| SettingsController | SettingsService |
| BackupExportController | BackupService, ExportService |
| OnboardingController | SettingsService |

## Communication Patterns

- **Data → Domain**: One-directional. Repositories never call services.
- **Domain → Domain**: Minimized by design (Q5 decision). The only permitted domain-to-domain call is ReportService → BudgetService, and it is read-only.
- **Presentation → Domain**: Controllers call one or more domain services directly. Multi-service orchestration (sequencing calls, branching on results) lives in the controller, never inside a domain service (see [services.md](services.md) Cross-Service Orchestration Pattern).
- **No Domain → Presentation**: Domain services never reference Riverpod or widget-layer types, keeping them independently unit/property-testable.

## Data Flow — Add Expense (illustrative, ties Q5 decision to a concrete flow)

```
User taps Save on Add Expense screen
        |
        v
AddEditExpenseController.save(input)
        |
        +--> ExpenseService.addExpense(input) --> ExpenseRepository.create() --> Isar
        |
        +--> BudgetService.recalculate(month, year, scope)
        |         |
        |         +--> ExpenseRepository.query(...)  [sum spend for the period]
        |         +--> BudgetRepository.getBudget(...)
        |
        +--> BudgetService.evaluateThresholds(month, year, scope)
        |         (applies "fire at most once per month" rule)
        |
        +--> [if thresholds crossed] NotificationService.notifyThresholdCrossed(crossing)
                  |
                  +--> flutter_local_notifications
```

## Data Flow — Automatic Nightly Backup (illustrative)

```
Platform scheduler trigger (mechanism finalized in NFR Design)
        |
        v
BackupService.runScheduledBackup()
        |
        +--> ExpenseRepository.query(all)
        +--> BudgetRepository.getBudgetHistory(all)
        +--> CategoryRepository.getAll()
        +--> SettingsRepository.getSettings()
        |
        v
   Assemble backup payload --> write to app-private storage (crash-safe/atomic write)
        |
        v
   BackupService.pruneOldBackups()  [retention policy]
```

## Dependency Direction Diagram (textual, per content-validation.md ASCII standards)

```
+----------------------------------------------------------+
|                    Presentation Layer                     |
|  OnboardingController  AddEditExpenseController           |
|  ExpenseListController  DashboardController                |
|  BudgetController  ReportsController  SettingsController  |
|  BackupExportController                                    |
+----------------------------------------------------------+
                        |  (calls)
                        v
+----------------------------------------------------------+
|                      Domain Layer                          |
|  ExpenseService  CategoryService  BudgetService            |
|  ReportService  NotificationService  BackupService         |
|  ExportService  SettingsService                            |
|                                                              |
|  ReportService --(read-only)--> BudgetService (only         |
|  permitted domain-to-domain call)                          |
+----------------------------------------------------------+
                        |  (calls)
                        v
+----------------------------------------------------------+
|                       Data Layer                           |
|  ExpenseRepository  BudgetRepository                       |
|  CategoryRepository  SettingsRepository                    |
+----------------------------------------------------------+
                        |
                        v
                   Isar (local DB)
```
