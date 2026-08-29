# Domain Entities — Unit 3: Budgeting & Notifications

No new persistent entities — consumes Budget/Expense from Unit 1. Introduces two transient value types:

## BudgetStatus (transient, computed)

| Field | Type | Description |
|---|---|---|
| month | int | |
| year | int | |
| ledgerScope | LedgerScope | |
| budgetAmount | double | From the Budget row, or 0 if none configured (BR-9's skippable-budget state) |
| amountSpent | double | Sum of matching Expense rows |
| remainingAmount | double | `budgetAmount - amountSpent` (can be negative if over budget) |
| percentageUsed | double | `amountSpent / budgetAmount * 100`, or 0 if `budgetAmount == 0` (avoids divide-by-zero) |
| hasBudgetConfigured | bool | False when no Budget row exists for this month/year/scope |

## ThresholdCrossing (transient, computed)

| Field | Type | Description |
|---|---|---|
| threshold | int | One of 50, 75, 90, 100 |
| month | int | |
| year | int | |
| ledgerScope | LedgerScope | |
| percentageUsed | double | The percentage at the moment of crossing |

## Threshold-Fired Tracking (new persistence need — resolves a gap not covered by Unit 1's schema)

**Problem identified**: BR-14 below (the "fire at most once per month" rule, per story-generation-plan.md Q6) requires remembering which thresholds have already fired for a given month/year/ledgerScope, across app restarts. Unit 1's `Budget` entity has no field for this.

**Decision**: Add a `firedThresholds: List<int>` field to the `Budget` entity (e.g., `[50, 75]` once both have fired this month). This is a schema addition to Unit 1's `Budget` model, made here because Unit 3 is the first unit that needs it — per unit-of-work-dependency.md's cross-unit interface contracts, schema changes to an earlier unit's entity are documented at the point of need and applied directly to the shared model file (not duplicated into a new entity).
