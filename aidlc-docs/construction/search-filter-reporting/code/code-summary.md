# Code Summary — Unit 5: Search, Filter, Sort & Reporting

## Application Code Created
- `lib/features/expense_management/domain/expense_filter.dart` — `ExpenseFilter`, `ExpenseSort`
- `lib/features/reporting/domain/report_results.dart` — `MonthlyTotal`, `CategoryTotal`, `LedgerComparison`, `MonthlyComparisonResult`
- `lib/features/reporting/domain/report_service.dart` — `ReportService`
- `lib/features/reporting/domain/report_providers.dart` — `reportServiceProvider`
- `lib/features/reporting/presentation/reports_controller.dart` — `ReportsController`
- `lib/features/reporting/presentation/reports_screen.dart` — `ReportsScreen` (6 tabs)
- `lib/features/expense_management/presentation/expense_filter_sheet.dart` — `showExpenseFilterSheet`

## Application Code Modified/Extended
- `lib/features/expense_management/domain/expense_service.dart` — added `searchExpenses` (BR-20), `filterAndSort` (BR-21/22/23)
- `lib/features/expense_management/presentation/expense_list_controller.dart` — added search/filter/sort state and setters
- `lib/features/expense_management/presentation/expense_list_screen.dart` — added search bar, filter button, sort menu
- `lib/features/dashboard/presentation/dashboard_controller.dart` — replaced the Unit 4 minimal aggregation with real `ReportService.categoryAnalysis()`/`monthlySpending()` calls
- `lib/features/dashboard/presentation/dashboard_screen.dart` — chart widgets updated for the new `List<CategoryTotal>`/`List<MonthlyTotal>` types
- `lib/app_router.dart` — Reports tab now uses the real `ReportsScreen`

## Tests Created/Modified
- `test/features/expense_management/domain/expense_service_search_filter_test.dart` — BR-20/21/22/23 example tests + glados PBT (filter AND-combination invariant)
- `test/features/reporting/domain/report_service_test.dart` — BR-24/25/26 example tests, including concrete-example checks of the "category totals sum to combined total" and "personal + home = combined" invariants
- `test/features/dashboard/presentation/dashboard_state_test.dart` — rewritten for `DashboardState`'s new field types

## Design Notes
- `ExpenseService.filterAndSort` does sorting in Dart (not via Isar query builder chains) because Isar's builder doesn't cleanly support a single parameterized sort direction across 4 different sort keys without duplicating the whole query per case — sorting a bounded, already-filtered result set in Dart is simpler and still fast at realistic per-query result sizes.
- `ReportService` is the one domain service with a permitted call into another (`BudgetService`, read-only, `budgetUtilization` only) — matches the Application Design exception documented in services.md.

## Known Limitation
Same SDK-unavailability caveat as prior units.
