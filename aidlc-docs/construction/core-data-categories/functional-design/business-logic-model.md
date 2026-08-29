# Business Logic Model — Unit 1: Core Data & Categories

## Overview
This unit implements two logical processes: (1) generic persistence for the four core entities, and (2) category lifecycle management (seeding, custom creation, deletion with reassignment). It is technology-agnostic in intent — Isar is the chosen implementation, but the logic below would hold for any embedded local database.

## Process 1: Entity Persistence (all 4 repositories)

**Inputs**: A domain entity instance (Expense, Budget, Category, or Settings) for writes; an id or query parameters for reads.

**Flow (write)**:
1. Caller (a domain service) constructs or mutates an entity object.
2. Repository validates nothing beyond type-level constraints (business validation happens in the calling service, per the layering established in Application Design).
3. Repository performs the Isar write inside a transaction.
4. On success, the persisted entity (with any auto-generated fields like `id`, `createdAt` populated) is returned.
5. On failure, a `RepositoryException` is thrown (BR-8) — no partial writes are visible to callers.

**Flow (read)**:
1. Caller supplies an id or query parameters (date range, category, etc. for Expense; month/year/scope for Budget).
2. Repository executes the Isar query and returns matching entities (or null/empty list if none found — this is a valid, non-error outcome).

**Outputs**: The entity (create/update/getById) or a list of entities (query methods), or a thrown exception.

## Process 2: Category Lifecycle

### 2a. Default Category Seeding
**Trigger**: Called by SettingsService during onboarding (US-01), and safe to call redundantly on every app launch as a defensive measure (BR-4).

**Flow**:
1. `CategoryService.ensureDefaultsSeeded()` queries CategoryRepository for existing categories where `isDefault == true`.
2. For each of the 13 PRD-specified default category names not already present, construct a Category entity (`isDefault: true`, PRD-specified icon/color) and persist it via CategoryRepository.
3. Categories already present are left untouched (idempotence, BR-4).

### 2b. Custom Category Creation
**Trigger**: User action (Settings/Category management UI, US-06).

**Flow**:
1. `CategoryService.createCustomCategory(input)` receives name, icon, color.
2. Check BR-1 (case-insensitive uniqueness) against all existing categories (default + custom). If violated, reject with a validation error — no repository call made.
3. Construct a Category entity with `isDefault: false` and the provided icon/color.
4. Persist via CategoryRepository.create().

### 2c. Category Deletion
**Trigger**: User action (US-06 open item, now resolved per BR-2/BR-3).

**Flow**:
1. `CategoryService.deleteCategory(id)` fetches the target Category.
2. If `isDefault == true`: reject immediately (BR-2) — no further action.
3. If `isDefault == false`: query ExpenseRepository for all Expense rows where `categoryId == id`.
4. If any exist: resolve the "Others" default category's id (by name lookup), then within a single Isar write transaction (BR-6): bulk-update those Expense rows' `categoryId` to the "Others" id, then delete the Category row.
5. If none exist: delete the Category row directly (still within a transaction for consistency, though there's nothing else to roll back).

## Error Scenarios Summary

| Scenario | Handling |
|---|---|
| Duplicate category name (case-insensitive) | Rejected at CategoryService before any repository call (BR-1) |
| Attempt to delete/rename a default category | Rejected at CategoryService (BR-2) |
| Isar I/O failure (disk full, corruption) during any repository operation | `RepositoryException` thrown, propagated to caller (BR-8) |
| Crash mid-reassignment during category deletion | Prevented by transactional write (BR-6) — either the full reassign+delete completes, or neither does |
| `ensureDefaultsSeeded()` called after defaults already exist | No-op for existing categories, safe to call repeatedly (BR-4) |

## Frontend Components
Not applicable for this unit — Unit 1 has no dedicated screens (per unit-of-work.md, its feature folders `core_data/` and `categories/` provide data/domain-layer capability consumed by later units' UI). Category management UI (the actual Settings screen affordance for adding/editing/deleting custom categories) is designed in Unit 6's Functional Design (Backup, Export & Settings), which owns the Settings screen presentation layer.
