# Tech Stack Decisions — Unit 3: Budgeting & Notifications

## Android Notification Channel
**Decision**: A single notification channel, `budget_alerts` (importance: default, not high — these are informational, not urgent-interrupt notifications), created once at app startup via `flutter_local_notifications`' Android-specific initialization.
**Rationale**: Android 8+ requires a channel for any notification; a single channel is sufficient since this app has only one notification category (budget alerts) in its current scope (end-of-month summary, FR-7.1, reuses the same channel).

## Decimal Package Usage Point
**Decision**: `BudgetService.recalculate()` is the first and primary consumer of the `decimal` package selected in Unit 1's tech-stack-decisions.md — confirming that decision was correctly scoped ahead of need.
