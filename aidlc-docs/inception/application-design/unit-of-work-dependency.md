# Unit of Work Dependency — Expense Tracker

## Dependency Matrix

| Unit | Depends On | Depended On By |
|---|---|---|
| 1. Core Data & Categories | (none — foundation) | 2, 3, 4, 5, 6 |
| 2. Onboarding & Expense Management | 1 | 3, 4, 5, 6 |
| 3. Budgeting & Notifications | 1, 2 | 4, 5 |
| 4. Dashboard | 1, 2, 3 (and reads a subset of what 5 later provides) | 7 |
| 5. Search, Filter, Sort & Reporting | 1, 3 | 7 |
| 6. Backup, Export & Settings | 1, 2 | 7 |
| 7. Premium Polish | 1, 2, 3, 4, 5, 6 | (none — final) |

## Build Sequence

```
Unit 1 (Core Data & Categories)
    |
    v
Unit 2 (Onboarding & Expense Management)
    |
    v
Unit 3 (Budgeting & Notifications)
    |
    +-------------------+
    v                    v
Unit 4 (Dashboard)   Unit 5 (Search/Filter/Sort & Reporting)
    |                    |
    +---------+----------+
              v
Unit 6 (Backup, Export & Settings)
              |
              v
Unit 7 (Premium Polish)
```

**Note**: Units 4 and 5 both depend only on Units 1-3, so they could in principle be designed/built in either order or interleaved — but per Q4 (solo/sequential build), they are still completed one at a time. Unit 4 is sequenced before Unit 5 in [unit-of-work.md](unit-of-work.md) because the Dashboard's category breakdown chart can ship with minimal aggregation and be wired to the full ReportService once Unit 5 lands, whereas Unit 5 has no dependency on Unit 4.

## Cross-Unit Interface Contracts (Strict Boundary Enforcement, Q2)

Per the approved strict-boundary decision, later units call only the following public interfaces of earlier units — never their repositories or private internals directly:

| Consuming Unit | Calls Into | Public Interface Used |
|---|---|---|
| Unit 2 | Unit 1 | `CategoryService.*`, `BudgetService.setBudgetAmount()` |
| Unit 3 | Unit 1 | `BudgetRepository` (internal to BudgetService only — BudgetService is defined across Units 1/3, see split note below) |
| Unit 3 | Unit 2 | Extends `AddEditExpenseController`'s orchestration sequence |
| Unit 4 | Unit 1, 2, 3 | `BudgetService.getBudgetStatus()`, `ExpenseService` read methods |
| Unit 5 | Unit 1 | `ExpenseRepository` (internal to ExpenseService's new query methods) |
| Unit 5 | Unit 3 | `BudgetService.getBudgetStatus()` (for US-19 budget utilization) |
| Unit 6 | Unit 1 | All 4 repositories (via BackupService/ExportService) |
| Unit 6 | Unit 2 | `ExpenseService` read methods (via ExportService) |
| Unit 7 | All | Presentation-layer widgets/controllers only (no new domain calls) |

## Special Case: BudgetService Split Across Units 1 and 3

`BudgetService.setBudgetAmount()` ships in **Unit 1** (simple upsert, needed by Unit 2's onboarding flow) while `BudgetService.recalculate()` and `BudgetService.evaluateThresholds()` ship in **Unit 3** (full threshold business logic). This is documented here explicitly because it is the one component that doesn't cleanly belong to a single unit — Functional Design for Unit 1 and Unit 3 must both reference this file to avoid re-defining the same class inconsistently.

## Shared Resource: Isar Database Instance

All units share a single Isar database instance, initialized once in Unit 1 and injected (via Riverpod) into every repository used by later units. No unit re-initializes or duplicates the database connection.
