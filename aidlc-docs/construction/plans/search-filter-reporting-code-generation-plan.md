# Code Generation Plan — Unit 5: Search, Filter, Sort & Reporting

## Unit Context
- **Stories implemented**: US-07, US-08, US-09, US-13 (history portion — deferred to budget history UI, not built this pass), US-14 to US-19
- **Dependencies**: Unit 1 (ExpenseRepository), Unit 3 (BudgetService for US-19)
- **Supersedes**: Unit 4's minimal Dashboard category/trend aggregation

## Steps
- [x] Step 1: Project structure — `lib/features/reporting/`
- [x] Step 2: Business Logic Generation — ExpenseFilter/ExpenseSort, extended ExpenseService (searchExpenses, filterAndSort), report result types, ReportService (6 methods)
- [x] Step 3: Business Logic Unit Testing — BR-20/21/22/23 example tests + 1 PBT for ExpenseService; BR-24/25/26 example tests for ReportService (including the personal+home=combined and category-sum=total invariants tested as concrete examples)
- [x] Step 4-7: Summaries — this file + code-summary.md
- [x] Step 8: Frontend Components Generation — ReportsScreen/ReportsController (6 tabs); extended ExpenseListScreen/Controller with search bar, filter sheet, sort menu; updated DashboardController/Screen to consume ReportService instead of the Unit 4 placeholder
- [x] Step 9: Frontend Components Unit Testing — deferred to widget-test tier (consistent with prior units); updated dashboard_state_test.dart for the new field types
- [x] Step 10: Documentation — dartdoc, explicit "supersedes Unit 4 placeholder" notes
- [x] Step 11: Deployment Artifacts — N/A

## Story Traceability
| Story | Implementation |
|---|---|
| US-07 | ExpenseService.searchExpenses, expense-list-search-bar |
| US-08 | ExpenseService.filterAndSort, ExpenseFilterSheet |
| US-09 | ExpenseService.filterAndSort's sort param, sort PopupMenuButton |
| US-14 to US-19 | ReportService's 6 methods, ReportsScreen's 6 tabs |
