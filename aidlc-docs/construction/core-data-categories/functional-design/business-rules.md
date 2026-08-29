# Business Rules — Unit 1: Core Data & Categories

## BR-1: Category Name Uniqueness (Case-Insensitive)
**Rule**: No two Category rows may have the same `name` when compared case-insensitively.
**Enforced by**: CategoryService, before calling CategoryRepository.create() or .update().
**Rationale**: Prevents user confusion from near-duplicate categories ("Food" vs "food") and keeps category-based aggregation (reports) from silently splitting what the user considers one category.
**Failure behavior**: `createCustomCategory()` rejects with a validation error identifying the conflicting existing category name.

## BR-2: Default Category Protection
**Rule**: Categories with `isDefault == true` cannot be deleted or renamed.
**Enforced by**: CategoryService.
**Rationale**: The 13 PRD-specified default categories (Food, Groceries, Fuel, Utilities, Shopping, Medical, Education, Travel, Entertainment, Investment, Rent, Gifts, Others) are assumed to always exist as a baseline; allowing their removal could leave the app with zero categories or break the "Others" catch-all used in BR-3.
**Failure behavior**: Delete/rename attempts on a default category are rejected before reaching the repository.

## BR-3: Custom Category Deletion — Reassign to "Others"
**Rule**: When a custom (`isDefault == false`) category with existing Expense references is deleted, all Expense rows referencing it are updated to reference the "Others" default category (id resolved by name lookup at seed time) before the Category row is deleted.
**Enforced by**: CategoryService.deleteCategory(), which must query ExpenseRepository for affected rows, bulk-update their `categoryId`, then delete the Category row — as a single logical operation (see BR-6 on atomicity).
**Rationale**: Resolves Application Design open item #1. Chosen over blocking deletion (worse UX) or leaving orphaned references (confusing in reports/UI).
**Failure behavior**: If a category with `isDefault == true` is targeted, this rule does not apply — BR-2 rejects the operation first.

## BR-4: Default Category Seeding Idempotence
**Rule**: `CategoryService.ensureDefaultsSeeded()` may be called any number of times (e.g., on every app launch) without ever creating duplicate default categories.
**Enforced by**: CategoryService checks for existing default categories (by name) before inserting; only missing ones are inserted.
**Rationale**: Simplifies call-site logic (SettingsService can safely call this during onboarding without needing to track "have I seeded already" state itself) and is directly required by the PBT-01 idempotence property identified in the plan (Q7).

## BR-5: Settings Singleton Enforcement
**Rule**: Exactly one Settings row exists at all times, with `id == 1`.
**Enforced by**: SettingsRepository — `getSettings()` creates the row with default values on first access if it doesn't exist (lazy singleton init); `updateSettings()` always writes to `id == 1`. No `createSettings()` or `deleteSettings()` method is exposed.
**Rationale**: Removes an entire class of "which settings row is active" bugs by construction rather than convention.

## BR-6: Repository Operations Are Atomic Per Call
**Rule**: Any repository method that touches multiple rows (e.g., BR-3's category-deletion reassignment) must complete as a single atomic Isar write transaction — either all affected rows update and the category deletes, or nothing changes.
**Enforced by**: Isar's transaction API (`isar.writeTxn()`), used by CategoryService when performing the BR-3 sequence.
**Rationale**: Prevents a crash or error mid-operation from leaving Expense rows pointing at a deleted category (a data-integrity concern flagged for this unit given it's the local-data-integrity analog under the Resiliency Baseline extension — see NFR Requirements for this unit).

## BR-7: Amount and Budget Value Positivity
**Rule**: `Expense.amount > 0` and `Budget.budgetAmount > 0` always; zero and negative values are rejected.
**Enforced by**: At the entity-write boundary — repositories reject invalid values defensively, though the primary validation point is the calling service (ExpenseService in Unit 2, BudgetService in Unit 3) per requirements.md FR-1.2/FR-3.1.
**Rationale**: Matches stories.md US-02 AC2 and US-11 AC4. Documented here since Unit 1 owns the schema-level constraint even though the primary UX-facing validation lives in later units.

## BR-8: Repository Error Surfacing
**Rule**: All repository methods that can fail (Isar I/O errors, corruption, constraint violations) throw a typed `RepositoryException` (with a `cause` and `operation` context) rather than returning null/silently swallowing errors.
**Enforced by**: Repository implementations wrap Isar calls in try/catch and rethrow as `RepositoryException`.
**Rationale**: Q6 decision — idiomatic Dart error handling, integrates directly with Riverpod's `AsyncValue.error` state in the presentation layer, and satisfies Security Baseline SECURITY-15 (fail-safe defaults, explicit error handling on all external I/O).

## Testable Properties (PBT-01 — Property-Based Testing Extension)

Per the enabled Property-Based Testing extension and the Q7 decision, this unit identifies the following testable properties, carried forward as PBT test requirements into Code Generation:

| Property | Category | Applies To | Statement |
|---|---|---|---|
| Round-trip persistence | Round-trip | ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository | For any valid entity `e`, `repository.getById(repository.create(e).id) == e` (all fields equal) |
| Category name uniqueness | Invariant | CategoryService | For any sequence of create/update operations, no two categories ever have case-insensitive-equal names |
| Seeding idempotence | Idempotence | CategoryService.ensureDefaultsSeeded() | Calling `ensureDefaultsSeeded()` N times produces the same set of default categories as calling it once (no duplicates) |

No components in this unit are marked N/A for PBT — all four repositories and CategoryService have at least one identified property.
