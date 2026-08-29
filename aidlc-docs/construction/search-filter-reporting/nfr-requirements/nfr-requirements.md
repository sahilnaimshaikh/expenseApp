# NFR Requirements — Unit 5: Search, Filter, Sort & Reporting

## Performance
- **NFR-2 (500,000+ records)**: Report aggregations must not load the entire dataset into memory when a narrower query is possible — all report methods query by date range first (using Unit 1's indexed `date` field), then aggregate only the matched subset.
- Search must feel instant (PRD Section 11 "Instant search") — for typical result-set sizes (a single month/category), in-memory Dart filtering after an indexed date-range fetch is fast enough without a dedicated full-text search index.

## Reliability
RESILIENCY-01: Report accuracy is classified **Critical** by extension — an incorrect report undermines the PRD's core "understand your spending" value proposition (Section 3) same as Unit 3's budget accuracy.

## Security / Maintainability
No new considerations. `filterAndSort`'s validation (BR-22) is this unit's SECURITY-05 input-validation analog.

## Tech Stack
No new dependencies — reuses `fl_chart` (Unit 4) for report visualizations.
