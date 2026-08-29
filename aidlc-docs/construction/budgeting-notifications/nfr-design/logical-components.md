# Logical Components — Unit 3: Budgeting & Notifications

## BudgetService (extended)
Extends Unit 1's `BudgetService` class in place (`lib/features/core_data/domain/budget_service.dart`) — adds `getBudgetStatus`, `recalculate`, `evaluateThresholds`, `updateNotificationThresholds` to the existing class rather than creating a second BudgetService.

## NotificationService (new)
Plain Dart class wrapping `FlutterLocalNotificationsPlugin`, exposed via a Riverpod `Provider` initialized once at app startup.

## BudgetController (new, presentation)
Riverpod `Notifier` for the Budget screen.
