# Requirements Clarification Questions

I've read the PRD you added (`Product Requirements Document (PRD) for expense tracker.docx`, saved as [prd-expense-tracker.md](prd-expense-tracker.md)). It covers most of what's needed — a Flutter/Android, offline-first, single-user expense tracker with a prescribed tech stack (Isar, Riverpod, Go Router, FL Chart, flutter_local_notifications).

A few gaps and one internal contradiction remain before I can finalize requirements.

## Question 1: Success criteria contradiction
Section 15 (Success Criteria) states expenses should be recorded "in under a second," but Section 1 (Executive Summary) and Section 9.2 (Add Expense) both target "under 10 seconds." Which is the real target?

A) 10 seconds is correct (Section 15 has a typo/error)

B) Under 1 second is the real target for the Add Expense flow

C) Both matter: sub-second for the tap-to-save action, ~10 seconds for the full entry including typing amount/category

X) Other (please describe after [Answer]: tag below)

[Answer]: It should be lightning fast, ignore that phrase

## Question 2: Initial build scope
The PRD defines 4 phases (MVP → Analytics → Productivity → Premium Experience). How much should I plan/build right now?

A) Full PRD scope across all 4 phases in this workflow

B) Phase 1 (MVP) only for now — Expense CRUD, categories, ledgers, dashboard, budgets, listing — with later phases as separate follow-up requests

C) Phase 1 + Phase 2 (MVP + Analytics/Reports/Search/Filters) now, defer Backup/Export/Settings polish

X) Other (please describe after [Answer]: tag below)

[Answer]: A)

## Question 3: Default currency
The PRD lists "UPI" as a payment method (suggesting India) but never states a default currency. How should currency be handled?

A) Default to INR (₹), configurable later in Settings

B) Ask the user to pick a currency on first launch (onboarding step)

C) Default to a generic/locale-detected currency, configurable in Settings

X) Other (please describe after [Answer]: tag below)

[Answer]: INR

## Question 4: Budget scope (Personal vs Home)
Section 5.3 describes a single "Monthly Budget Amount," but Section 5.2 says budgets/dashboards support Personal-only, Home-only, and Combined views. Should there be one combined monthly budget, or separate budgets per ledger?

A) One single combined monthly budget (covers Personal + Home together)

B) Separate monthly budgets for Personal and Home (each with its own amount and notification thresholds)

C) Both — a combined budget by default, with optional separate per-ledger budgets

X) Other (please describe after [Answer]: tag below)

[Answer]: C)

## Question 5: Custom category appearance
Should user-created custom categories support choosing an icon and color (like the default categories), or use a fixed generic icon/color?

A) Full icon + color picker for custom categories, same as defaults

B) Fixed generic icon/color for all custom categories (simpler, faster to build)

X) Other (please describe after [Answer]: tag below)

[Answer]: A)

## Question 6: First-launch experience
Should the app pre-seed default categories, a default currency, and an empty budget silently on first launch, or show an onboarding/setup wizard?

A) Silent pre-seeding — no onboarding screens, app opens straight to Dashboard

B) Short onboarding wizard (currency, initial monthly budget) before first Dashboard view

X) Other (please describe after [Answer]: tag below)

[Answer]: B)

## Question: Resiliency Extensions
Should the resiliency baseline be applied to this project?

**What this extension is.** Enabling it applies a set of **directional, design-time best practices** for building resilient systems, derived from the **AWS Well-Architected Framework (Reliability Pillar)** and resilience-review guidance. It steers requirements, design, and code toward fault tolerance, high availability, observability, and recoverability — covering 15 practice areas across business goals, change management, observability, high availability, disaster recovery, and continuous improvement.

**What this extension is NOT.** Enabling it does **not** make your workload production-ready, nor does it certify or guarantee any availability, RTO, or RPO target. It is a **starting point** that scaffolds good resiliency decisions early — it is not a substitute for a formal **AWS Well-Architected Review** of the built system.

**Note for this project**: this is a fully offline, local-storage-only mobile app with no backend/cloud infrastructure, so most cloud-reliability practices (multi-AZ, disaster recovery, etc.) won't apply — but concepts like local data-integrity, crash-safe writes, and graceful degradation still could.

A) Yes — apply the resiliency baseline as directional best practices and design-time guidance

B) No — skip the resiliency baseline (suitable for this PoC/personal-use app where rapid iteration matters more)

X) Other (please describe after [Answer]: tag below)

[Answer]: A)

## Question: Security Extensions
Should security extension rules be enforced for this project? Even though the app is offline with no auth/backend, it stores sensitive personal financial data locally (backups included).

A) Yes — enforce all SECURITY rules as blocking constraints (recommended given the app stores financial data and produces backup files)

B) No — skip all SECURITY rules (suitable for a prototype/experimental build)

X) Other (please describe after [Answer]: tag below)

[Answer]: A)

## Question: Property-Based Testing Extension
Should property-based testing (PBT) rules be enforced? This app has non-trivial business logic (budget calculations, category aggregation, filtering/sorting, CSV/Excel/JSON export round-trips) that could benefit from PBT.

A) Yes — enforce all PBT rules as blocking constraints

B) Partial — enforce PBT rules only for pure functions and serialization round-trips (e.g., export/import, budget math)

C) No — skip all PBT rules

X) Other (please describe after [Answer]: tag below)

[Answer]:A)
