# Business Logic Model — Unit 5: Search, Filter, Sort & Reporting

## Process 1: Search (US-07)
`ExpenseService.searchExpenses(query)`: fetches all expenses (bounded by a reasonable window, e.g. current view's date range if the caller supplies one) and CategoryRepository's category list once, then filters in Dart per BR-20 (Isar doesn't support full-text OR-across-fields queries natively for this shape).

## Process 2: Filter + Sort (US-08, US-09)
`ExpenseService.filterAndSort(filter, sort)`: validates the amount range (BR-22), builds an Isar query via chained `.optional()` calls (BR-21), applies the requested sort with BR-23's stable tie-break, and returns the result. This method supersedes Unit 2's simpler `listExpenses` for any UI that needs filtering — `listExpenses` remains for the plain paginated case (Dashboard's recent-expenses fetch).

## Process 3: Report Generation (US-14 to US-19)
Each `ReportService` method queries `ExpenseRepository` for the relevant date range/scope, aggregates in Dart (with decimal-safe summation, consistent with Unit 3's BR-18 pattern), and applies BR-24's zero-bucket inclusion. `budgetUtilization` (US-19) is the exception — pure delegation to `BudgetService` (BR-26).

## Superseding Unit 4's Placeholder Aggregation
This unit's `ReportService.categoryAnalysis()` and `ReportService.monthlySpending()` **replace** Unit 4's `DashboardState.categoryBreakdown`/`dailyTrend` minimal aggregations. Per the sequencing note documented in both units, `DashboardController` is updated here (not duplicated) to call the real `ReportService` methods instead of computing its own minimal aggregation from `recentExpenses`.

## Error Scenarios
| Scenario | Handling |
|---|---|
| `minAmount > maxAmount` | BR-22 — validation exception before any query executes |
| Report requested for a period with zero expenses | BR-24 — returns zero-valued entries, not an empty/error result |
| Search query is empty string | Returns all expenses (equivalent to no filter) — not treated as an error |

## Frontend Components

### Reports Screen (US-14 to US-19)
- **Hierarchy**: `ReportsScreen` → `PeriodSelector` → `TabBar` (Monthly Spending / Category / Personal vs Home / Top Categories / Comparison / Utilization) → per-tab chart widgets
- **State**: `ReportsController` — `selectedPeriod`, per-report cached results, `isLoading`
- **Automation-friendly Keys**: `reports-period-selector`, `reports-tab-monthly`, `reports-tab-category`, `reports-tab-personal-home`, `reports-tab-top-categories`, `reports-tab-comparison`, `reports-tab-utilization`

### Search/Filter UI (extends Expense List, US-07/US-08/US-09)
- **Hierarchy**: `ExpenseListScreen` (Unit 2) gains a `SearchBar` + `FilterSheet` (bottom sheet with category/type/payment/date-range/amount-range fields) + `SortDropdown`
- **State**: `ExpenseListController` (extended) gains `searchQuery`, `activeFilter`, `activeSort` fields
- **Automation-friendly Keys**: `expense-list-search-bar`, `expense-list-filter-button`, `expense-list-sort-dropdown`, `expense-filter-sheet-apply-button`, `expense-filter-sheet-clear-button`
