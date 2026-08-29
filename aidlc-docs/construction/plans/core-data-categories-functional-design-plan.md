# Functional Design Plan — Unit 1: Core Data & Categories

## Unit Context

**Responsibility** (from [unit-of-work.md](../../inception/application-design/unit-of-work.md)): Establish the Isar database, all four repositories (Expense, Budget, Category, Settings), and category management — the foundation every other unit depends on.

**Components in scope**: ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository, CategoryService, and `BudgetService.setBudgetAmount()` only (full BudgetService ships in Unit 3).

**Stories in scope**: US-06 (Manage Categories — Default + Custom).

**Note**: Although only US-06 is "owned" by this unit, this unit also defines the domain entities (Expense, Budget, Category, Settings) that ALL other units' functional designs will reference — so entity/schema design here has system-wide impact, even though CRUD-consumer business logic (expense validation, budget math, etc.) is designed in later units' Functional Design stages.

## Execution Checklist

- [x] Step 1: Answer clarifying questions below (domain model, business rules, data flow, error handling, PBT properties)
- [x] Step 2: Analyze answers for ambiguity; issue follow-ups if needed
- [x] Step 3: Generate `business-logic-model.md`
- [x] Step 4: Generate `business-rules.md`
- [x] Step 5: Generate `domain-entities.md`
- [ ] Step 6: Present for review and approval

## Decisions Recorded (per user instruction: decide directly, don't ask repeatedly)

- **Q1 → C) Decimal-safe arithmetic library for computation, Double for Isar storage.** Best balance: avoids float-drift bugs in budget summation/percentage math (the actual risk area) without deviating from the PRD's stated schema (Double) or adding an integer-conversion layer (B) that complicates every read/write path for marginal benefit at personal-app scale.
- **Q2 → A) Add `isDefault: bool` field.** Directly needed to support the category-deletion policy (Q3) and gives the UI a clean, schema-backed way to prevent renaming/deleting defaults, rather than relying on a hardcoded name list that would break if the user renames a "default" category.
- **Q3 → B) Reassign affected expenses to "Others" automatically, then allow deletion.** Best UX for a personal app — avoids blocking the user (A) or leaving orphaned/confusing "(Deleted Category)" references in their financial history (C). Matches the spirit of default categories always including "Others" as a catch-all (PRD Section 5.1).
- **Q4 → B) Isar-enforced singleton pattern**, `SettingsRepository` always uses a constant id and exposes no create/delete — prevents an entire class of bugs (accidental duplicate settings rows) at the repository level rather than relying on every call site remembering the convention (A).
- **Q5 → A) Single Budget schema with a `ledgerScope` enum field** (Combined/Personal/Home), one row per scope per month. Cleaner than parallel nullable fields (B) — extends naturally if category-wise budgets are added in a future version (PRD Section 5.3), and matches the ReportService/BudgetService method signatures already defined in component-methods.md (`LedgerScope scope` parameter).
- **Q6 → A) Repositories throw typed exceptions.** Idiomatic Dart/Flutter error handling (matches Isar's own exception-based API), integrates cleanly with standard try/catch and Riverpod's `AsyncValue` error states in the presentation layer — a Result/Either type (B) would require introducing a new pattern/dependency with no material benefit at this app's scale.
- **Q7 → C) All three properties apply**: round-trip (all 4 repositories), category-name-uniqueness invariant, and `seedDefaults()` idempotence. This is the most complete correct answer — none of the three are mutually exclusive, and all three are cheap, high-value properties to test given PBT is fully enforced for this project.

---

## Clarifying Questions

### Question 1: Expense Entity — Amount Precision
The PRD specifies `amount` as a Double (Section 10). Financial amounts stored as floating-point can introduce rounding errors (e.g., 0.1 + 0.2 != 0.3). Given budget percentage calculations depend on summing many amounts, how should amount precision be handled?

A) Store as Double as the PRD specifies, but round all displayed/aggregated values to 2 decimal places for INR — acceptable given personal (non-accounting-grade) use

B) Store amounts as integer paise/cents internally (e.g., ₹150.50 stored as 15050) to avoid floating-point drift entirely, converting to/from Double only at the UI boundary — deviates from the PRD's literal schema but avoids known float pitfalls

C) Store as Double, but use a decimal-safe arithmetic library (e.g., `decimal` package) for all summation/percentage logic, converting to Double only for Isar storage

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 2: Category Entity — Default vs Custom Distinction
Should the schema distinguish default categories from custom (user-created) ones at the data level?

A) Yes — add an `isDefault: bool` field so the app can prevent deletion/renaming of default categories differently from custom ones (ties into the open item on category-deletion policy)

B) No — treat all categories identically in the schema; any default-vs-custom UI distinction is purely presentation-layer (e.g., a hardcoded list of default names)

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 3: Custom Category Deletion Policy (resolves Application Design open item #1)
When a user deletes a custom category that has existing expenses assigned to it, what should happen to those expenses?

A) Block deletion entirely if any expense references the category — user must reassign/delete those expenses first

B) Reassign affected expenses to the "Others" default category automatically, then allow deletion

C) Allow deletion; affected expenses keep a now-orphaned category reference, and the UI displays it as "(Deleted Category)" — no data migration needed

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 4: Settings Entity — Singleton Enforcement
The PRD models Settings as a "collection" but conceptually there's only ever one settings record per app install. How should this be enforced?

A) Application-level convention only — always query/update the record with a fixed known id (e.g., id=1); Isar schema doesn't enforce singleton-ness itself

B) Use Isar's built-in support for a fixed-id singleton pattern explicitly in the schema/repository (e.g., `SettingsRepository` always uses `Isar.put()` with a constant id, never exposes create/delete)

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 5: Budget Entity — Combined vs Per-Ledger Storage
requirements.md FR-3.2 confirms combined-by-default with optional per-ledger budgets. How should this be represented in the Budget schema (still Unit 1's concern since it owns the schema, even though full budget logic is Unit 3)?

A) A single Budget schema with a `ledgerScope` field (enum: Combined/Personal/Home); "combined mode" = one record with scope=Combined per month; "split mode" = two records (Personal + Home) per month, no Combined record that month

B) Two separate fields on one record per month (`combinedBudgetAmount`, `personalBudgetAmount`, `homeBudgetAmount`, nullable) — one row per month regardless of mode

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 6: Error Handling — Repository-Level Failures
Isar operations can theoretically fail (disk full, corruption). How should repository methods surface failures to calling services?

A) Repositories throw typed exceptions (e.g., `RepositoryException`) that services catch and translate into domain-level results; no silent failures anywhere

B) Repositories return a Result/Either type (success or typed failure) rather than throwing, for explicit error handling at every call site

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 7: Property-Based Testing — Property Identification for This Unit (PBT-01)
Per the enabled Property-Based Testing extension, this unit's testable properties must be identified now. Based on this unit's scope (repositories + CategoryService), which properties apply?

A) Round-trip: writing an entity (Expense/Budget/Category/Settings) to Isar and reading it back yields an equal object — applies to all 4 repositories

B) Invariant: CategoryService prevents duplicate category names (case-insensitive) — always holds after any create/update sequence

C) Both A and B apply, plus: Idempotence — calling `seedDefaults()` multiple times never creates duplicate default categories

X) Other (please describe after [Answer]: tag below)

[Answer]:
