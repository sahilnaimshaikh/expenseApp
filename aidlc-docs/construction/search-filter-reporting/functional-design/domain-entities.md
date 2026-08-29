# Domain Entities — Unit 5: Search, Filter, Sort & Reporting

No new persistent entities. Introduces transient query/result value types.

## ExpenseFilter (transient)

| Field | Type |
|---|---|
| searchText | String? |
| startDate / endDate | DateTime? |
| categoryId | int? |
| expenseType | ExpenseType? |
| paymentMethod | PaymentMethod? |
| minAmount / maxAmount | double? |

## ExpenseSort (enum, transient)
`newestFirst`, `oldestFirst`, `highestAmount`, `lowestAmount`

## Report Result Types (all transient)

- **MonthlyTotal**: `{month, year, total}` — US-14
- **CategoryTotal**: `{categoryId, categoryName, total}` — US-15, US-17
- **LedgerComparison**: `{personalTotal, homeTotal}` — US-16
- **MonthlyComparisonResult**: `{currentMonthTotal, priorMonths: List<MonthlyTotal>}` — US-18
