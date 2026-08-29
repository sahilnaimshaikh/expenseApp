# Business Logic Model — Unit 4: Dashboard

## Overview
Per unit-of-work.md, the Dashboard "has no business logic of its own — it must come after the units producing the data it displays." This unit adds zero new domain-layer code; it is entirely a presentation-layer aggregation of Units 1-3's existing services.

## Process: Dashboard Load (US-10)

**Flow** (`DashboardController.load`):
1. Call `BudgetService.getBudgetStatus(currentMonth, currentYear, LedgerScope.combined)` for the budget card/progress bar.
2. Call `ExpenseService.listExpenses(limit: 5)` for "Recent Expenses" (Unit 2's existing method, already sorted newest-first).
3. Call `BudgetService.getBudgetStatus(..., LedgerScope.personal)` and `(..., LedgerScope.home)` for the Personal vs Home summary.
4. **Category breakdown chart**: per unit-of-work.md's sequencing note, this unit ships a minimal aggregation (grouping the 5-50 most recent expenses by category, computed in the Dashboard controller itself) rather than waiting for Unit 5's full `ReportService`. This is superseded (not duplicated) once Unit 5 lands — Unit 5's Functional Design must replace this minimal aggregation with a call to `ReportService.categoryAnalysis()`.
5. **Monthly trend graph**: same minimal-aggregation approach — computed from the same recent-expenses fetch, grouped by day, until Unit 5's `ReportService.monthlySpending()` supersedes it.

## Business Rules
No new BR-numbered rules — this unit only composes existing rules (BR-9's `hasBudgetConfigured` flag drives the "no budget set" empty state on the Dashboard, reusing BudgetScreen's same pattern).

## Error Scenarios
| Scenario | Handling |
|---|---|
| No budget configured | Dashboard shows a "Set a budget" prompt card instead of the progress bar (reuses `BudgetStatus.hasBudgetConfigured`) |
| Zero expenses ever recorded | Recent Expenses section shows an empty-state message; category/trend charts render an empty-state placeholder rather than an error |

## Frontend Components

### Dashboard Screen
- **Hierarchy**: `DashboardScreen` → `GreetingHeader` → `BudgetSummaryCard` (reused pattern from BudgetScreen) → `PersonalVsHomeSummaryCard` → `CategoryBreakdownChart` (minimal, superseded in Unit 5) → `MonthlyTrendChart` (minimal, superseded in Unit 5) → `RecentExpensesList` → `QuickAddFAB`
- **State**: `DashboardController` — `combinedStatus`, `personalStatus`, `homeStatus`, `recentExpenses`, `isLoading`
- **User interactions**: tap Quick-Add FAB → navigate to `/expense/add` (Unit 2's existing route)
- **Automation-friendly Keys**: `dashboard-budget-card`, `dashboard-personal-home-summary`, `dashboard-category-chart`, `dashboard-trend-chart`, `dashboard-recent-expenses-list`, `dashboard-quick-add-fab`
