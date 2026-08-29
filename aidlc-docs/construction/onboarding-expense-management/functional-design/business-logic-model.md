# Business Logic Model — Unit 2: Onboarding & Expense Management

## Process 1: First-Launch Onboarding (US-01)

**Flow**:
1. App startup checks `SettingsService.isOnboardingComplete()`.
2. If false: show onboarding wizard collecting currency (default "INR", editable) and an optional initial monthly budget.
3. On "Continue"/"Finish": `SettingsService.completeOnboarding(currency, initialBudgetAmount)`:
   a. `SettingsRepository.updateSettings()` — sets `currency`, `onboardingComplete = true`.
   b. `CategoryService.ensureDefaultsSeeded()`.
   c. If `initialBudgetAmount != null`: `BudgetService.setBudgetAmount(currentMonth, currentYear, LedgerScope.combined, initialBudgetAmount)` (BR-9 — skippable).
4. Navigate to Dashboard (Unit 4 — for this unit, navigate to the Unit 1 scaffold placeholder until Unit 4 lands, per unit-of-work.md's sequencing note).
5. If true (already onboarded): skip wizard, go straight to Dashboard.

**Validation errors**: negative/zero budget amount rejected inline (BudgetValidationException surfaces as a form validation message); empty currency rejected (falls back to "INR" if left blank rather than blocking).

## Process 2: Add Expense (US-02)

**Flow**:
1. User fills Add Expense form: amount (required), category (required, defaults to first category), expense type (required, defaults to last-used or Personal), optionally description/payment method/date/tags.
2. On Save: `AddEditExpenseController.save(input)` calls `ExpenseService.addExpense(input)`.
3. `ExpenseService.addExpense`: validates (BR-10), defaults date if absent (BR-11), constructs `Expense` with `createdAt = updatedAt = now`, persists via `ExpenseRepository.create()`.
4. Controller returns success; UI navigates back to Expense List / Dashboard.
5. **Budget/notification integration** (added fully in Unit 3): once Unit 3 lands, this same controller method extends to call `BudgetService.recalculate()` and `evaluateThresholds()` after step 3. For Unit 2 alone, this integration point exists as a documented extension seam (a no-op stub) rather than a partial/broken implementation.

## Process 3: Edit Expense (US-03)

**Flow**: Same as Add, but `ExpenseService.editExpense(id, input)` fetches the existing expense, applies BR-12 (preserve createdAt), validates (BR-10), and calls `ExpenseRepository.update()`.

## Process 4: Delete Expense (US-04)

**Flow**: `ExpenseService.deleteExpense(id)` calls `ExpenseRepository.delete(id)` directly — no cascading concerns (Expense is a leaf entity with no children).

## Process 5: Expense List (US-05)

**Flow**:
1. `ExpenseListController` watches `ExpenseRepository.watchAll()` (or a `query()` call for Unit 2's baseline; full search/filter/sort UI wiring is Unit 5's scope, but the list screen itself — grouped by date, swipe actions, multi-select — is built now).
2. Groups results by date in the presentation layer (pure UI concern, no new domain method needed).
3. Swipe-left → calls `deleteExpense`; swipe-right → navigates to Edit; long-press → enters multi-select mode, calls the new `deleteMany` (BR-13) on bulk-delete confirmation.

## Process 6: Manage Custom Categories UI (US-06, custom-category portion)

**Note**: `CategoryService` itself is Unit 1's scope (already implemented). Unit 2 does not add a dedicated category-management screen (that's Unit 6's Settings screen) — Unit 2 only needs a category *picker* widget (dropdown/list) for the Add/Edit Expense form, which reads via `CategoryService`/`CategoryRepository` but adds no new business logic.

## Error Scenarios

| Scenario | Handling |
|---|---|
| Add/Edit Expense with amount <= 0 | BR-10 rejects before repository call; UI shows inline validation |
| Add/Edit Expense with invalid categoryId | BR-10 rejects (category picker should make this unreachable in practice, but service-layer validation still applies defensively) |
| Bulk delete where one expense no longer exists (already deleted elsewhere) | Isar's delete is a no-op for missing ids; BR-13's transaction still commits successfully for the remaining valid ids |
| Onboarding budget left blank | BR-9 — proceeds without creating a Budget row |

## Frontend Components

### Onboarding Wizard Screen
- **Hierarchy**: `OnboardingScreen` → `CurrencyStep` → `InitialBudgetStep` (optional, skippable) → `CompletionAction`
- **State**: `OnboardingController` (Riverpod `Notifier`) holds `currency: String`, `initialBudgetAmount: double?`, `isSubmitting: bool`
- **User interactions**: text/dropdown for currency, numeric input for budget (with a visible "Skip" affordance), a "Get Started" button
- **Validation**: budget field validates `> 0` if non-empty; currency defaults silently if left blank
- **Automation-friendly**: `data-testid`-equivalent Flutter `Key`s: `onboarding-currency-input`, `onboarding-budget-input`, `onboarding-skip-budget-button`, `onboarding-submit-button`

### Add/Edit Expense Screen
- **Hierarchy**: `AddEditExpenseScreen` → `AmountInput` (large numeric) → `ExpenseTypeToggle` (Personal/Home) → `CategoryPicker` → `DescriptionInput` (optional) → `PaymentMethodPicker` (optional) → `DatePickerField` → `TagsInput` (optional) → `SaveButton`
- **State**: `AddEditExpenseController` — `amount`, `categoryId`, `expenseType`, `date`, `description`, `paymentMethod`, `tags`, `isSaving`, `errorMessage`
- **User interactions**: numeric keypad focus on load (for speed), single-tap category/type selection, optional fields visually de-emphasized
- **Validation**: Save button disabled until amount > 0, category selected, expense type selected (BR-10's UI-side mirror)
- **Automation-friendly Keys**: `expense-amount-input`, `expense-type-personal-button`, `expense-type-home-button`, `expense-category-picker`, `expense-description-input`, `expense-payment-method-picker`, `expense-date-picker`, `expense-tags-input`, `expense-save-button`

### Expense List Screen
- **Hierarchy**: `ExpenseListScreen` → `DateGroupHeader` (repeated) → `ExpenseCard` (repeated, swipeable) → `MultiSelectActionBar` (shown conditionally)
- **State**: `ExpenseListController` — `expenses: List<Expense>` (grouped by date in a derived getter), `selectedIds: Set<int>`, `isMultiSelectMode: bool`
- **User interactions**: swipe-left (delete), swipe-right (edit), long-press (enter multi-select), tap-while-multi-select (toggle selection)
- **Validation**: N/A (read/action screen, not a form)
- **Automation-friendly Keys**: `expense-list-card-{id}`, `expense-list-empty-state`, `expense-list-multiselect-delete-button`
