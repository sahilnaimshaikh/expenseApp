# Requirements — Expense Tracker

## Intent Analysis Summary

- **User Request**: Build an offline-first personal expense tracker Android app, per the attached PRD (`Product Requirements Document (PRD) for expense tracker.docx`, archived as [prd-expense-tracker.md](prd-expense-tracker.md)).
- **Request Type**: New Project (Greenfield)
- **Scope Estimate**: System-wide — new mobile application spanning data layer, business logic, and multiple UI screens.
- **Complexity Estimate**: Moderate — well-specified domain (expense/budget CRUD, reporting, notifications) with a prescribed tech stack, but touches many cross-cutting concerns (offline storage at scale, charts, notifications, backup/export).
- **Depth Applied**: Standard — the source PRD is thorough; clarifying questions targeted PRD contradictions/gaps and extension opt-ins rather than first-principles requirements gathering.

## Source Documents
- [prd-expense-tracker.md](prd-expense-tracker.md) — full product requirements document (converted from the user-provided .docx)
- [requirement-verification-questions.md](requirement-verification-questions.md) — clarifying questions and answers (PRD gaps/contradictions + extension opt-ins)
- [resiliency-clarification-questions.md](resiliency-clarification-questions.md) — Resiliency Baseline applicability follow-up and answers

## Decisions Resolved During Requirements Analysis

| Topic | Decision |
|---|---|
| Expense-entry speed target | "Lightning fast" — no fixed numeric SLA. (PRD Section 15's "under a second" contradicted Sections 1/9.2's "under 10 seconds"; user directed to drop the specific number.) |
| Build scope for this workflow | Full 4-phase PRD scope (MVP → Analytics → Productivity → Premium Experience) |
| Default currency | INR (₹), configurable later in Settings |
| Budget structure | Combined monthly budget by default; user may optionally configure separate Personal and Home budgets |
| Custom category styling | Full icon + color picker, same UX as default categories |
| First-launch experience | Onboarding wizard collecting currency and initial monthly budget, before first Dashboard view |
| Local backup cadence | Automatic silent nightly local backup to app-private storage, in addition to on-demand manual export (ZIP/CSV/Excel/JSON) — fully on-device, no cloud |

## Extension Configuration

| Extension | Enabled | Notes |
|---|---|---|
| Resiliency Baseline | Yes | Most cloud-oriented rules (RESILIENCY-03,04,05,06,07,08,09,10,11,13,14,15) are **N/A** — confirmed by user — because this app has no backend, no cloud infrastructure, and runs on a single device. RESILIENCY-01 (criticality) and the RESILIENCY-02/12 analog (local data-loss tolerance) apply and are captured below. |
| Security Baseline | Yes | Full rule set enforced at applicable stages. Many network/API/auth-specific rules (SECURITY-02, 04, 05, 06, 07, 08, 12) will be **N/A** by nature of this being a local-only app with no network endpoints, no server, and no user authentication — this will be confirmed explicitly during Application/NFR Design once component boundaries are known, and marked N/A there rather than blocking. Rules with clear local-app relevance — SECURITY-01 (local data encryption at rest), SECURITY-03 (structured logging without leaking sensitive data), SECURITY-09 (hardening/error handling), SECURITY-10 (dependency/supply-chain hygiene), SECURITY-13 (data integrity, e.g., safe backup/restore deserialization), SECURITY-15 (fail-safe error handling) — apply. |
| Property-Based Testing | Yes (Full enforcement) | Applies to budget math, category aggregation, filtering/sorting, and CSV/Excel/JSON export-import round-trips during Functional Design and Code Generation. |

## Functional Requirements

### FR-1 Expense Management
- FR-1.1: Users can create, edit, delete, and search expense records.
- FR-1.2: Each expense has: amount (required), category (required), expense type — Personal or Home (required), date (required), description (optional), payment method (optional: Cash, UPI, Debit Card, Credit Card, Bank Transfer), tags (optional, custom, searchable), createdAt/updatedAt (system-generated).
- FR-1.3: The app ships with default categories: Food, Groceries, Fuel, Utilities, Shopping, Medical, Education, Travel, Entertainment, Investment, Rent, Gifts, Others.
- FR-1.4: Users can create custom categories with a user-chosen icon and color (same UX as default categories).

### FR-2 Ledger Separation (Personal / Home)
- FR-2.1: Every expense belongs to exactly one ledger: Personal or Home.
- FR-2.2: Dashboards, budgets, and reports support Personal-only, Home-only, and Combined views.

### FR-3 Budget Management
- FR-3.1: The app supports monthly budgeting with: budget amount, amount spent, remaining amount, percentage used.
- FR-3.2: By default, one combined monthly budget covers both ledgers; users may optionally configure separate Personal and Home budgets instead.
- FR-3.3: Users can configure local notification thresholds at 50%, 75%, 90%, and 100% of budget.
- FR-3.4: The app generates a local notification when spending crosses a configured threshold.
- FR-3.5 (Future/V2): Category-wise budgets.

### FR-4 Search & Filtering
- FR-4.1: Search by description, category, tags, or payment method.
- FR-4.2: Filter by month, year, date range, category, expense type, payment method, and amount range.
- FR-4.3: Sort by newest first, oldest first, highest amount, lowest amount.

### FR-5 Reports
- FR-5.1: Monthly spending totals.
- FR-5.2: Category analysis (spending grouped by category).
- FR-5.3: Personal vs Home comparison.
- FR-5.4: Top spending categories ranking.
- FR-5.5: Monthly comparison (current vs previous months).
- FR-5.6: Budget utilization percentage.

### FR-6 Dashboard
- FR-6.1: Dashboard is the first screen on app open (after onboarding, if first launch).
- FR-6.2: Displays: greeting, current month, monthly budget card, budget progress indicator, Personal vs Home summary, category breakdown chart, monthly spending trend graph, recent expenses, quick-add button.

### FR-7 Notifications
- FR-7.1: Local notifications for budget threshold reached, budget exceeded, and (optional) end-of-month summary.
- FR-7.2: All notifications work fully offline.

### FR-8 Backup & Restore
- FR-8.1: Manual backup and restore of the full local database, settings, and categories, packaged as a ZIP archive.
- FR-8.2: Automatic silent nightly local backup to app-private storage (in addition to manual export) — no cloud transmission.
- FR-8.3: Data export in CSV, Excel, and JSON formats.
- FR-8.4 (Future/V2): Receipt image attachments included in backup.

### FR-9 Onboarding
- FR-9.1: On first launch, present a short onboarding wizard collecting currency (defaulting to INR) and an initial monthly budget amount, before showing the Dashboard.

### FR-10 Settings
- FR-10.1: Theme (Dark / Light / System), currency, notification preferences, backup & restore actions, data export, about screen.

## Non-Functional Requirements

- NFR-1 (Performance): App launches within 2 seconds; adding an expense feels instantaneous ("lightning fast" — no fixed numeric target); UI maintains 60 FPS animations.
- NFR-2 (Scale): Efficiently handles 500,000+ expense records.
- NFR-3 (Offline): 100% offline operation — no backend services, no cloud infrastructure, no user authentication.
- NFR-4 (Battery): Minimal battery consumption.
- NFR-5 (Compatibility): Supports Android Dark Mode; responsive across phones and tablets.
- NFR-6 (Resiliency — local-data analog): Automatic nightly local backups minimize data loss from device loss/corruption without requiring user action (see FR-8.2); backup/restore operations use crash-safe, atomic file writes.
- NFR-7 (Security — local-data): Local database and backup files are encrypted at rest where the platform/library supports it; no sensitive data (financial amounts, descriptions) is written to logs; error paths fail safely without exposing internal details.
- NFR-8 (Testability): Business logic with identifiable properties (budget math, aggregation, filtering/sorting, import/export round-trips) is covered by property-based tests in addition to example-based tests.

## Technical Constraints (from PRD, non-negotiable)

- Platform: Android (Flutter, Dart)
- Local Database: Isar
- State Management: Riverpod
- Routing: Go Router
- Charts: FL Chart
- Local Notifications: flutter_local_notifications
- No backend services, no cloud infrastructure, no user authentication

## Out of Scope (V2 / Future Roadmap, per PRD Section 13)

Income tracking, multiple wallets, bank/credit card accounts, recurring expenses, receipt image attachments, financial goals, savings/investment tracking, subscription management, PIN lock, biometric auth, home screen widgets, optional cloud sync.

## Summary

This is a greenfield, single-user, fully offline Android expense-tracking app built with Flutter/Isar/Riverpod. Full 4-phase PRD scope (MVP, Analytics, Productivity, Premium Experience) is planned. Key resolved decisions: INR default currency, combined-by-default budgets with optional per-ledger split, onboarding wizard on first launch, and automatic nightly local backups alongside manual export. Resiliency and Security baselines are enabled but most cloud/network-specific rules are N/A given the offline, backend-less architecture — this is noted for design stages to avoid false blocking findings. Property-based testing is fully enforced for budget math, aggregation, filtering, and import/export round-trips.
