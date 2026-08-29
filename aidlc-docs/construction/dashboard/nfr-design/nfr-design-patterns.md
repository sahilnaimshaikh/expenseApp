# NFR Design Patterns — Unit 4: Dashboard

## Performance Patterns
- **Concurrent load pattern**: `DashboardController.load()` uses `Future.wait([...])` to fetch combined/personal/home budget statuses and recent expenses concurrently, rather than awaiting each sequentially — directly supports NFR-1's 2s launch target.

## Logical Components
- **DashboardController**: Riverpod `Notifier`, the only new logical component this unit introduces. No new services (pure aggregator, per business-logic-model.md).
