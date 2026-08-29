# NFR Design Patterns — Unit 5: Search, Filter, Sort & Reporting

## Performance Patterns
- **Narrow-then-aggregate pattern**: every ReportService method queries the indexed date range first, then aggregates in Dart — never aggregates across the unfiltered full table.

## Logical Components
- **ReportService**: new domain service, depends on ExpenseRepository (read) and BudgetService (read, for `budgetUtilization` only — BR-26).
- **ReportsController**: new presentation Notifier.
