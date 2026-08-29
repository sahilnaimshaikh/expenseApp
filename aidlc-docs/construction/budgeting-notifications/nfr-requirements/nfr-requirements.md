# NFR Requirements — Unit 3: Budgeting & Notifications

## Performance
- `recalculate()` must sum expenses for a single month efficiently even at 500,000+ total records — relies on `ExpenseRepository.query()`'s indexed date-range filter (Unit 1), never a full-table scan.
- Threshold evaluation must add negligible latency to the Add/Edit Expense save flow (NFR-1 "lightning fast") — recalculation + evaluation together should add no more than ~50ms perceived delay for a typical month's expense count.

## Reliability
- RESILIENCY-01: Budget calculation and notification dispatch are classified **Critical** (same tier as Unit 1's data) — an incorrect budget percentage or a missed notification directly undermines the app's core value proposition (PRD Section 3, Product Vision).
- BR-16's separation of recalculate/evaluateThresholds ensures a notification-dispatch failure (e.g., OS permission denied) never corrupts or blocks the budget calculation itself — a resilience/graceful-degradation pattern.

## Security
Consistent with Units 1-2's determination. No new considerations — `flutter_local_notifications` requires no network access and no new SECURITY rule becomes applicable.

## Maintainability
- `firedThresholds` as a `List<int>` on `Budget` (rather than 4 separate boolean fields like `fired50`, `fired75`, etc.) was chosen for extensibility — if a 5th threshold is ever added, no schema migration is needed, just a new value in the list.

## Tech Stack
`flutter_local_notifications` (already pinned in pubspec.yaml) is used for the first time in this unit. Android notification channel setup (required for API 26+) is this unit's one new platform-integration concern.
