# Business Rules — Unit 3: Budgeting & Notifications

## BR-14: Threshold Fires At Most Once Per Month (story-generation-plan.md Q6, Answer A)
**Rule**: For a given (month, year, ledgerScope), each of the 4 thresholds (50/75/90/100) fires a notification at most once, regardless of how many times spend crosses back and forth over it via subsequent add/edit/delete operations within that same month.
**Enforced by**: `BudgetService.evaluateThresholds()` checks `Budget.firedThresholds` before returning a crossing as "new"; any threshold already in that list is never returned again this month. On a new month (different month/year), a fresh Budget row (or none) means `firedThresholds` starts empty again.
**Rationale**: Directly resolves stories.md US-12 AC2/AC3 and the story-generation-plan.md Q6 decision — prevents notification spam from edits/deletes.

## BR-15: Threshold Evaluation Only Considers Enabled Thresholds
**Rule**: `evaluateThresholds()` only returns crossings for thresholds where the corresponding `Budget.notifyXX` flag is `true`. If a user disables a threshold after it already fired, it simply never appears again (already in `firedThresholds` and/or now disabled — both suppress it).
**Enforced by**: BudgetService.

## BR-16: Recalculation Never Fires Notifications Itself
**Rule**: `recalculate()` only recomputes and returns a `BudgetStatus` — it never touches `firedThresholds` or fires a notification. Only `evaluateThresholds()` (called separately, always immediately after `recalculate()` at the call site) can mark a threshold as fired.
**Rationale**: Keeps the two responsibilities (computing current status vs. deciding what's notify-worthy) cleanly separable and independently testable — directly supports the PBT properties below.

## BR-17: Percentage Calculation Avoids Divide-by-Zero
**Rule**: If `budgetAmount == 0` (no budget configured, BR-9's skippable state), `percentageUsed` is defined as `0`, and `hasBudgetConfigured` is `false` — callers (Dashboard, Budget screen) must check `hasBudgetConfigured` before displaying a percentage, rather than trusting a possibly-meaningless 0%.

## BR-18: Spend Summation Uses Decimal-Safe Arithmetic
**Rule**: `recalculate()`'s summation of matching Expense amounts uses the `decimal` package (per Unit 1's tech-stack-decisions.md Q1 resolution) — never raw `double` addition in a loop — converting to `double` only in the final `BudgetStatus.amountSpent` field.
**Rationale**: This is the exact scenario Unit 1's NFR Requirements flagged this dependency for — cumulative sums over potentially many Expense rows.

## BR-19: Combined vs Per-Ledger Spend Attribution
**Rule**: When `ledgerScope == LedgerScope.combined`, spend summation includes ALL expenses for the month regardless of their `ExpenseType` (both Personal and Home). When `ledgerScope` is `personal` or `home`, only expenses with the matching `ExpenseType` are summed.
**Enforced by**: BudgetService, via `ExpenseRepository.query()`'s existing `expenseType` filter (used only for personal/home scope; omitted for combined).

## Testable Properties (PBT-01)

| Property | Category | Applies To | Statement |
|---|---|---|---|
| Threshold fires at most once per month | Invariant | evaluateThresholds | For any sequence of add/edit/delete operations within one month, each of the 4 thresholds appears in the returned crossings list at most once across the entire sequence |
| Percentage calculation invariant | Invariant | recalculate | For any generated set of expense amounts and any positive budgetAmount, `percentageUsed == (sum of amounts / budgetAmount) * 100`, within decimal-arithmetic tolerance |
| No divide-by-zero | Invariant | recalculate | For any `budgetAmount == 0`, `percentageUsed == 0` and no exception is thrown |
| Combined-scope spend equals personal + home spend | Invariant | recalculate | For any set of expenses, `recalculate(combined).amountSpent == recalculate(personal).amountSpent + recalculate(home).amountSpent` |
