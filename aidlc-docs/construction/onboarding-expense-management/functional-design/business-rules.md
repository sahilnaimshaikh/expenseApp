# Business Rules — Unit 2: Onboarding & Expense Management

## BR-9: Onboarding Budget Is Skippable (resolves Application Design open item #4)
**Decision**: The initial budget amount in onboarding is optional. If the user skips it, `SettingsService.completeOnboarding()` still seeds default categories and marks `onboardingComplete = true`, but does not create any Budget row. The Dashboard/Budget screen (Units 3/4) must handle the "no budget configured yet" state gracefully (e.g., prompt to set one, rather than assuming a Budget row always exists).
**Rationale**: Blocking app usage on a budget decision the user may not be ready to make yet is worse UX than a graceful "set it later" path — matches the PRD's "premium, effortless" design philosophy (PRD Section 7).

## BR-10: Expense Validation (traces to requirements.md FR-1.2, stories.md US-02)
**Rule**: `ExpenseService.addExpense`/`editExpense` reject an `ExpenseInput` if:
- `amount <= 0`
- `categoryId` does not reference an existing Category
- `expenseType` is null (always required — enforced by Dart's non-nullable type, no runtime check needed)
**Enforced by**: ExpenseService, before calling ExpenseRepository.

## BR-11: Default Date on Creation
**Rule**: If `ExpenseInput.date` is not supplied, `addExpense` defaults it to "today" (the device's current date) at call time.
**Rationale**: Directly implements the Q7-decided "lightning fast" definition (4-interaction save: amount, category, type, Save — date defaults, not entered).

## BR-12: Edit Preserves createdAt, Refreshes updatedAt
**Rule**: `editExpense` never modifies `createdAt`; it always sets `updatedAt` to the current time on any successful edit.
**Enforced by**: ExpenseService.editExpense.

## BR-13: Multi-Select Bulk Delete Is Transactional
**Rule**: When multiple expenses are deleted via multi-select (stories.md US-05 AC3), the deletion of all selected expenses happens as a single logical operation — if one delete fails, none of the batch is committed (matches BR-6's atomicity pattern from Unit 1).
**Enforced by**: ExpenseService.deleteMany (new method beyond component-methods.md's single `deleteExpense`, added here to support US-05's bulk-delete acceptance criterion) wrapping repository calls in an Isar transaction.

## Testable Properties (PBT-01)

| Property | Category | Applies To | Statement |
|---|---|---|---|
| Amount positivity invariant | Invariant | ExpenseService.addExpense/editExpense | For any generated `ExpenseInput` with `amount <= 0`, the call always throws a validation exception; for any `amount > 0` with a valid `categoryId`, it always succeeds |
| Edit preserves createdAt | Invariant | ExpenseService.editExpense | For any sequence of edits to the same expense, `createdAt` never changes while `updatedAt` strictly increases (or stays equal under a fixed clock in tests) |

No PBT properties identified for the presentation-layer controllers in this unit (thin orchestration only, per Application Design Q4 — not a business-logic component).
