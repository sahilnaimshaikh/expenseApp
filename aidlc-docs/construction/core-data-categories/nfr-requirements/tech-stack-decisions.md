# Tech Stack Decisions — Unit 1: Core Data & Categories

## Fixed by PRD / requirements.md (no decision needed)
- Language: Dart
- Local Database: Isar
- State Management: Riverpod (consumed by later units, not this unit directly)

## Decisions Made for This Unit

### Decimal-Safe Arithmetic Library
**Decision**: Use the `decimal` package (pub.dev) for all summation and percentage calculations performed by services that consume this unit's repositories (BudgetService in Unit 3, ReportService in Unit 5) — resolving Functional Design Q1.
**Rationale**: Avoids floating-point drift in cumulative sums over potentially hundreds of thousands of Expense rows, without deviating from the PRD's `Double` storage schema. Well-maintained, no native dependencies, integrates trivially at service boundaries (convert Double → Decimal for math, Decimal → Double only when writing back to Isar).
**Scope note**: The dependency is declared in this unit's `pubspec.yaml` scope since it operates on data this unit owns, but is primarily consumed by Units 3 and 5.

### Property-Based Testing Framework — Dart
**Decision**: Use **`glados`** (pub.dev) as the PBT framework for this project (PBT-09).
**Rationale**: The property-based-testing.md extension's example table does not list a Dart framework. Among Dart PBT options, `glados` is the most actively maintained and widely adopted (integrates with Dart's built-in `test` package, supports custom generators, automatic shrinking, and seed-based reproducibility — satisfying PBT-08's requirements). Alternative considered: hand-rolled property tests using `package:test` + manual random generation — rejected because it would require reimplementing shrinking and seed-reproducibility from scratch, which `glados` already provides.
**Applies to**: All 3 properties identified in business-rules.md (round-trip persistence, category name-uniqueness invariant, seeding idempotence), and will be reused by all subsequent units' PBT test requirements.

### Isar Index Configuration
**Decision**: Add Isar `@Index()` annotations on:
- `Expense.date`, `Expense.categoryId`, `Expense.expenseType`, `Expense.paymentMethod`
- `Budget`: composite unique index on `(month, year, ledgerScope)`
- `Category.name`: unique index (case-insensitive handled at service layer per BR-1, since Isar's native index is case-sensitive — the index accelerates lookups, the service enforces the case-insensitive business rule)

**Rationale**: Directly supports NFR-2 (500,000+ records) query performance for filtering/sorting operations that Units 2 and 5 will build on top of this repository layer. The Budget composite index provides a database-level backstop against the uniqueness invariant in domain-entities.md, defense-in-depth alongside the service-layer check.

### Dependency Management (SECURITY-10)
**Decision**: `pubspec.lock` committed to version control from the first commit; Isar, `decimal`, and `glados` pinned to exact versions (no `^` caret ranges in production dependencies beyond what `flutter pub` requires for SDK compatibility).
**Rationale**: Satisfies SECURITY-10 supply-chain requirements; establishes the pattern for all subsequent units' dependencies.
