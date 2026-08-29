# Unit of Work Plan — Expense Tracker

**Context**: This is a monolith (single Flutter app, single deployable). Per units-generation.md's definition, "units of work" here are **logical development groupings** within that one app — not independently deployable services. They exist to sequence Functional Design → NFR Requirements → NFR Design → Code Generation per the approved execution-plan.md, in an order that respects dependencies (e.g., data/category layer before reporting).

## Execution Checklist

- [x] Step 1: Answer clarifying questions below (grouping strategy, dependencies/integration, code organization)
- [x] Step 2: Analyze answers for ambiguity; issue follow-ups if needed
- [x] Step 3: Generate `unit-of-work.md`
- [x] Step 4: Generate `unit-of-work-dependency.md`
- [x] Step 5: Generate `unit-of-work-story-map.md`
- [x] Step 6: Validate all 24 stories are assigned to a unit
- [ ] Step 7: Present for review and approval

## Decisions Recorded (user delegated: "You can do it the way you think its better")

- **Q1 → A) Use the proposed 7-unit decomposition as-is.** Reconsidered the merge alternatives (B, C) against build order: Dashboard (unit 4) reads from Budgeting (unit 3) and Reporting (unit 5), so collapsing Dashboard into unit 2 (option B) would force it to be built before its own dependencies exist, causing rework. The 7-unit sequence already respects data dependencies correctly.
- **Q2 → A) Strict boundaries**, but scoped to service-level exports, not full directory-firewalling — later units may only call earlier units' public domain-service methods (never reach into another unit's repository or private helpers directly). This preserves the "no cross-domain side-effect calls" invariant established in [services.md](../application-design/services.md), which is valuable even for a solo build because it keeps each unit's tests isolated and prevents hidden coupling as the app grows toward Premium Experience polish.
- **Q3 → A) Feature-first**: `lib/features/{feature}/{data,domain,presentation}/`. Chosen over layer-first because each unit of work IS a feature grouping — feature-first folders let each unit's Code Generation stage produce a fully self-contained folder, matching the per-unit CONSTRUCTION loop in execution-plan.md. This is also the pattern used in Flutter's official architecture guidance for Riverpod apps.
- **Q4 → A) Solo/sequential.** Matches the CLAUDE.md-mandated per-unit loop (each unit's design + code fully completed before the next unit starts) and the single-developer context of this project.
- **Q5 → A) No technical differentiation across units.** All units share the same offline-only, 500k-record-scale, 60 FPS constraints; nothing in requirements.md or stories.md suggests otherwise.

### Cross-Unit Coordination Note (surfaced during dependency analysis)
Onboarding (Unit 2, US-01) calls `SettingsService.completeOnboarding()`, which needs `BudgetService.setBudgetAmount()` to create the user's initial budget — but full `BudgetService` (with threshold evaluation/recalculation) is scoped to Unit 3. Resolution: `BudgetService.setBudgetAmount()` (a simple upsert wrapping BudgetRepository, no threshold logic) ships as part of **Unit 1's** foundational scope alongside the repositories; `recalculate()` and `evaluateThresholds()` ship in Unit 3. This split is documented in [unit-of-work.md](../application-design/unit-of-work.md) and [unit-of-work-dependency.md](../application-design/unit-of-work-dependency.md).

---

## Proposed Unit Candidates (for reference while answering)

Based on components.md's 8 domain services and stories.md's 8 epics/4 phases, a natural decomposition is:

1. **Core Data & Categories** — Isar setup, all 4 repositories, CategoryService, default category seeding (foundation for everything else)
2. **Onboarding & Expense Management** — SettingsService (onboarding piece), ExpenseService, Add/Edit/Delete/List screens (US-01 to US-06)
3. **Budgeting & Notifications** — BudgetService, NotificationService, Budget screen (US-11, US-12, US-13)
4. **Dashboard** — DashboardController aggregating Budget/Expense/Report data (US-10) — depends on units 2 & 3
5. **Search, Filter, Sort & Reporting** — ExpenseService's query methods, ReportService, all 6 report screens (US-07 to US-09, US-14 to US-19)
6. **Backup, Export & Settings** — BackupService, ExportService, SettingsService (ongoing settings), Settings screen (US-20, US-21, US-22)
7. **Premium Polish** — animations, accessibility, Material 3 refinement (US-23, US-24) — cross-cutting, touches all prior units

## Clarifying Questions

### Question 1: Grouping Strategy Confirmation
Does the proposed 7-unit decomposition above match how you'd like work sequenced, or would you prefer a different grouping?

A) Use the proposed 7-unit decomposition as-is

B) Merge some units — Dashboard is thin enough to fold into Onboarding & Expense Management (since Dashboard mostly displays data others already compute); reduces to 6 units

C) Fewer, larger units — collapse everything pre-Dashboard into two units (Foundation: Core Data+Categories+Expense Management; Money: Budgeting+Notifications+Dashboard+Reporting), keep Backup/Export/Settings and Premium Polish separate — 4 units total

D) I'll specify a custom breakdown (describe after [Answer]: tag below)

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 2: Dependency/Integration Approach
Since this is a single Flutter app with no network boundaries between units, how strictly should unit boundaries be enforced during Code Generation?

A) Strict — each unit's code lives in its own directory/package boundary (e.g., `lib/features/expense_management/`, `lib/features/budgeting/`) with explicit exports; later units may only import earlier units' public interfaces, never their internals

B) Loose — units guide the *order* and *design conversation* only; final code organization follows standard Flutter feature-folder conventions without strictly policing cross-unit imports

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 3: Code Organization Strategy (Greenfield)
What top-level project/folder structure should Code Generation follow?

A) Feature-first: `lib/features/{feature}/{data,domain,presentation}/` — each feature folder contains its own data/domain/presentation sub-layers (mirrors the unit breakdown directly)

B) Layer-first: `lib/{data,domain,presentation}/{feature}/` — top-level split by architectural layer (matches components.md's Data/Domain/Presentation layers directly), with feature sub-folders inside each

C) Standard Flutter/Riverpod starter convention (e.g., `lib/src/features/...` following the official Flutter architecture guide) — I'll follow whatever is idiomatic

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 4: Team Alignment
Is this being built solely by you (or your team) working through units sequentially, or do multiple people need to work on different units in parallel?

A) Solo/sequential — one unit fully designed and coded before starting the next, exactly as execution-plan.md's per-unit loop describes

B) Parallel — multiple units may be designed/coded concurrently by different people; unit boundaries need to be more independent to support this

X) Other (please describe after [Answer]: tag below)

[Answer]:

### Question 5: Technical/Deployment Considerations Across Units
Do any units have different technical constraints from the rest (e.g., a unit that must work fully offline vs. one that could theoretically need connectivity later, or a unit with materially higher performance requirements)?

A) No — all units share identical constraints: 100% offline, same performance/scale targets (2s launch, 500k+ records, 60 FPS) apply app-wide, no per-unit technical differentiation needed

B) Yes — some units have distinct considerations (describe after [Answer]: tag below)

X) Other (please describe after [Answer]: tag below)

[Answer]:
