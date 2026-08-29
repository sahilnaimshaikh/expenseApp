# Business Rules — Unit 5: Search, Filter, Sort & Reporting

## BR-20: Search Matches Description, Category Name, Tags, or Payment Method (case-insensitive)
**Rule**: `ExpenseService.searchExpenses(query)` matches if `query` (case-insensitive substring) appears in the expense's `description`, its resolved category `name`, any of its `tags`, or its `paymentMethod`'s display name.
**Rationale**: Directly implements requirements.md FR-4.1 / stories.md US-07.

## BR-21: Filters Combine with AND Logic
**Rule**: When multiple `ExpenseFilter` fields are set simultaneously, an expense must satisfy ALL of them to be included (stories.md US-08 AC2).
**Enforced by**: `ExpenseService.filterAndSort`, building on `ExpenseRepository.query()`'s existing `.optional()` chain (Unit 1) — each additional filter field adds another `.optional()` step, which is inherently AND-combining by construction.

## BR-22: Invalid Amount Range Rejected
**Rule**: If `ExpenseFilter.minAmount > maxAmount` (both set), `filterAndSort` throws a validation exception rather than silently returning an empty or nonsensical result (stories.md US-08 AC3).

## BR-23: Sort Stability
**Rule**: For amount-based sorts (`highestAmount`/`lowestAmount`), ties are broken by `id` ascending; for date-based sorts (`newestFirst`/`oldestFirst`), ties are broken by `id` ascending. Ensures deterministic, non-jittering order across repeated queries (stories.md US-09 AC2).

## BR-24: Report Aggregations Include Zero-Value Buckets
**Rule**: `monthlySpending`, `categoryAnalysis`, and `personalVsHome` must include months/categories/ledgers with zero spend in the requested range as explicit zero entries, not omit them (stories.md US-14 AC1, US-15 AC2, US-16 AC2).
**Rationale**: Prevents charts from silently dropping a category/month, which would look like a rendering bug rather than "no spend."

## BR-25: Top Categories Ranking Uses a Stable Tie-Break
**Rule**: `topCategories` ranks descending by total spend; categories with identical totals are ordered by `categoryId` ascending as a deterministic tie-break (stories.md US-17 AC2).

## BR-26: Budget Utilization Delegates to BudgetService (read-only composition)
**Rule**: `ReportService.budgetUtilization()` calls `BudgetService.getBudgetStatus()` internally and returns its `percentageUsed` — it does NOT reimplement budget math. This is the one permitted domain-to-domain call, per Application Design's services.md "Exception — read-only composition is allowed."

## Testable Properties (PBT-01)

| Property | Category | Applies To | Statement |
|---|---|---|---|
| Filter AND-combination invariant | Invariant | filterAndSort | Every returned expense satisfies every non-null field of the supplied filter |
| Sort ordering invariant | Invariant | filterAndSort | For any generated expense list and any ExpenseSort, the result is non-decreasing/non-increasing per the chosen sort key, with stable tie-breaking (BR-23) |
| Category totals sum to the combined total | Invariant | categoryAnalysis | The sum of all `CategoryTotal.total` values equals the overall total spend for the same period/scope |
| Personal + Home = Combined | Invariant | personalVsHome | `LedgerComparison.personalTotal + homeTotal` equals `monthlySpending` for the same period at combined scope (mirrors BR-19 from Unit 3) |
