# Business Logic Model — Unit 3: Budgeting & Notifications

## Process 1: Budget Status Computation (US-11, US-13 core)

**Flow** (`BudgetService.getBudgetStatus`/`recalculate`):
1. Fetch the Budget row for (month, year, scope) via BudgetRepository. If none exists, `budgetAmount = 0`, `hasBudgetConfigured = false` (BR-17).
2. Query matching Expenses (BR-19: filtered by ExpenseType for personal/home, unfiltered for combined) within the month's date range.
3. Sum amounts using decimal-safe arithmetic (BR-18).
4. Compute `remainingAmount = budgetAmount - amountSpent`, `percentageUsed` (BR-17's zero-guard).
5. Return a `BudgetStatus`.

## Process 2: Threshold Evaluation (US-12)

**Flow** (`BudgetService.evaluateThresholds`):
1. Call `recalculate()` to get current `percentageUsed`.
2. Fetch the Budget row (for `firedThresholds` and `notifyXX` flags).
3. For each of [50, 75, 90, 100]: if `notifyXX == true` AND `percentageUsed >= threshold` AND `threshold` not already in `firedThresholds` → it's a new crossing.
4. For each new crossing: add it to `firedThresholds`, persist the updated Budget row, and include it in the returned list (BR-14).
5. Return the list of new `ThresholdCrossing`s (empty if none).

## Process 3: Call-Site Orchestration Extension (extends Unit 2's AddEditExpenseController)

Per Application Design's Q5 decision (documented in Unit 2's code as an extension seam), `AddEditExpenseController.save()` is extended:

```
save(input, editingId):
  1. expense = ExpenseService.addExpense(input) OR editExpense(editingId, input)
  2. scope = expense.expenseType.toLedgerScope()
  3. BudgetService.recalculate(expense.date.month, expense.date.year, scope)
     AND BudgetService.recalculate(..., LedgerScope.combined)   [both scopes may have budgets]
  4. crossings = BudgetService.evaluateThresholds(..., scope) + evaluateThresholds(..., combined)
  5. for each crossing: NotificationService.notifyThresholdCrossed(crossing)
```

Likewise, `ExpenseListController.deleteOne`/`deleteSelected` (Unit 2) are extended to call `recalculate()` after deletion (BR-16 — recalculation alone, no notification fires on deletion, since only upward crossings via evaluateThresholds' "new crossing" logic can fire, and a deletion only decreases spend — evaluateThresholds naturally returns no new crossings in that case).

## Process 4: Notification Dispatch (US-12)

**Flow** (`NotificationService.notifyThresholdCrossed`): Formats a message ("You've used {threshold}% of your {scope} budget") and calls `flutter_local_notifications`' `show()`. No business logic — pure dispatch, consistent with Application Design's services.md description.

## Error Scenarios

| Scenario | Handling |
|---|---|
| No budget configured for the month (BR-9's skip path) | `hasBudgetConfigured = false`; UI shows "Set a budget" prompt instead of a percentage (Unit 4's concern to render, this unit's concern to signal via the flag) |
| Notification permission denied by the OS | `NotificationService.notifyThresholdCrossed` catches the platform exception and logs it (SECURITY-15 fail-safe) — budget calculation itself is unaffected; the user simply doesn't see the notification |
| Threshold flags all disabled | `evaluateThresholds` returns an empty list every time (BR-15) — recalculation still works normally |

## Frontend Components

### Budget Screen (US-13 core portion)
- **Hierarchy**: `BudgetScreen` → `BudgetSummaryCard` (amount/spent/remaining/progress) → `NotificationThresholdToggles` (4 switches)
- **State**: `BudgetController` — `status: BudgetStatus?`, `isLoading`, `errorMessage`
- **User interactions**: toggle switches call `BudgetService.setBudgetAmount`'s sibling method for updating `notifyXX` flags (new method: `updateNotificationThresholds`, added to BudgetService here since it wasn't in the original component-methods.md signature list but is needed for US-13 AC2)
- **Automation-friendly Keys**: `budget-amount-display`, `budget-progress-bar`, `budget-notify-50-toggle`, `budget-notify-75-toggle`, `budget-notify-90-toggle`, `budget-notify-100-toggle`, `budget-set-amount-button`
