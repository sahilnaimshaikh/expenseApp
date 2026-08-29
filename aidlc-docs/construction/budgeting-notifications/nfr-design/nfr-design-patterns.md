# NFR Design Patterns — Unit 3: Budgeting & Notifications

## Performance Patterns
- **Indexed date-range summation pattern**: `recalculate()` always queries via `ExpenseRepository.query(startDate, endDate, ...)`, using the `date` index from Unit 1 — never fetches all expenses and filters in memory.

## Reliability Patterns
- **Fail-safe notification dispatch pattern**: `NotificationService.notifyThresholdCrossed` wraps the platform call in try/catch; failures are logged (SECURITY-03/15) but never propagate as exceptions to the calling controller — a failed notification must never roll back or block the underlying expense save/budget recalculation that triggered it.
- **Separated compute/mutate pattern**: BR-16's split between `recalculate` (pure computation, side-effect-free on `firedThresholds`) and `evaluateThresholds` (the only method that mutates `firedThresholds`) — makes `recalculate` safely callable any number of times (e.g., for display refreshes) without any risk of accidentally suppressing a future legitimate threshold notification.

## Logical Components
- **NotificationService**: wraps `FlutterLocalNotificationsPlugin`, initialized once at app startup (alongside the Isar and GoRouter singletons) via a Riverpod provider.
- No new infrastructure components (queues/caches/etc.) — consistent with prior units.
