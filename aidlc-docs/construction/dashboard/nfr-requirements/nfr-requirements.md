# NFR Requirements — Unit 4: Dashboard

## Performance
- **NFR-1 (2s launch)**: Dashboard is the first screen after onboarding — its load-time IS the app's perceived launch time. All 3 `getBudgetStatus` calls (combined/personal/home) must run concurrently (`Future.wait`), not sequentially, to minimize load latency.
- Minimal category/trend aggregation (this unit's scope) must only process the small "recent expenses" fetch (≤50 rows), never the full 500,000+ row dataset — full-dataset aggregation is explicitly deferred to Unit 5's ReportService, which will use proper indexed aggregation.

## Reliability
- RESILIENCY-01: Dashboard itself is not classified as carrying critical data (it's a read-only view) — no new classification needed.

## Security / Maintainability
No new considerations beyond prior units. The minimal-aggregation-superseded-by-Unit-5 pattern is flagged as a maintainability note requiring follow-through (tracked in business-logic-model.md).

## Tech Stack
First use of `fl_chart` (pinned in pubspec.yaml since Unit 1) for the category breakdown and trend charts.
