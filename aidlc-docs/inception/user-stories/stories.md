# User Stories — Expense Tracker

**Persona**: All stories are written for [The Privacy-Conscious Budget Owner](personas.md) — the app's single user.
**Breakdown Approach**: Feature-Based (approved: [story-generation-plan.md](../plans/story-generation-plan.md), Q3)
**Granularity**: Screen-level (approved: Q2) — one story per screen/major interaction, each with multiple acceptance-criteria scenarios covering sub-behaviors
**Acceptance Criteria Format**: Comprehensive Given/When/Then — happy path, validation, and edge cases (approved: Q4)
**Phase Tags**: MVP / Analytics / Productivity / Premium Experience, per PRD Section 14 (approved: Q5)

**Business rules baked into acceptance criteria**:
- Budget notifications recalculate silently on edit/delete but never re-fire a previously-fired threshold within the same month (story-generation-plan.md Q6, Answer A).
- Add Expense "lightning fast" goal = 4 or fewer required interactions to save (amount, category, expense type, Save — date defaults to today) (story-generation-plan.md Q7, Answer A).

---

## Epic: Onboarding

### US-01: First-Launch Onboarding Wizard
**Phase**: MVP
**As a** first-time user, **I want** a short setup wizard when I open the app for the first time, **so that** the app is configured (currency, initial budget) before I start using it.

**Acceptance Criteria**:
1. **Given** the app is launched for the very first time (no prior local database), **when** the app opens, **then** an onboarding wizard is shown before the Dashboard, asking for currency (defaulting to INR) and an initial monthly budget amount.
2. **Given** I am on the onboarding wizard, **when** I confirm my currency and enter a monthly budget amount, **then** the app saves these settings, seeds the default category list, and navigates directly to the Dashboard.
3. **Given** I am on the onboarding wizard, **when** I leave the budget field empty and try to continue, **then** the app either requires a valid positive number or offers a clear "Skip for now, set up later in Settings" option (design decision needed downstream — flagged as an open item for Application/Functional Design).
4. **Given** I have already completed onboarding once, **when** I reopen the app later, **then** the onboarding wizard does NOT show again — the app opens directly to the Dashboard.
5. **Given** I am on the onboarding wizard, **when** I enter a non-numeric or negative budget value, **then** the app rejects the input with an inline validation message and does not proceed.

**INVEST Notes**: Independent of other screens; Small enough for one story; Testable via first-launch state detection.

---

## Epic: Expense Management

### US-02: Add Expense
**Phase**: MVP
**As a** user, **I want** to log a new expense in as few steps as possible, **so that** tracking spending doesn't interrupt my day.

**Acceptance Criteria**:
1. **Given** I am on the Add Expense screen, **when** I enter an amount, select a category, select an expense type (Personal/Home), and tap Save — with no other fields touched, **then** the expense is saved with today's date, no description, no payment method, no tags, in 4 interactions total (amount, category, type, Save).
2. **Given** I am on the Add Expense screen, **when** I leave the amount field empty or enter zero/negative, **then** Save is disabled or rejects with a validation message — amount, category, and expense type are mandatory.
3. **Given** I am on the Add Expense screen, **when** I optionally add a description, select a payment method, change the date, or add tags, **then** those values are saved along with the required fields.
4. **Given** I save a new expense that pushes the relevant monthly budget over a configured notification threshold, **when** the save completes, **then** a local notification fires per the Budget Threshold Notifications rules (see US-13).
5. **Given** I am on the Add Expense screen, **when** I select "Home" as the expense type, **then** the expense is attributed to the Home ledger and excluded from Personal-only views (and vice versa for Personal).

**INVEST Notes**: Core, high-value story; Estimable given the fixed field set from requirements.md FR-1.2; Testable via the 4-interaction save path.

---

### US-03: Edit Expense
**Phase**: MVP
**As a** user, **I want** to correct or update an existing expense, **so that** my records stay accurate.

**Acceptance Criteria**:
1. **Given** an existing expense, **when** I open it for editing and change any field (amount, category, type, date, description, payment method, tags) and save, **then** the expense is updated and `updatedAt` is refreshed; `createdAt` is unchanged.
2. **Given** I edit an expense's amount or category such that it moves the relevant monthly budget's spend total, **when** I save the edit, **then** the budget percentage/progress bar recalculates immediately, following the silent-recalculation rule (US-13, Q6 Answer A) — no duplicate notification for a threshold already fired this month.
3. **Given** I edit an expense's expense type (Personal → Home or vice versa), **when** I save, **then** the expense moves to the new ledger's budget/report calculations and is removed from the old ledger's totals.
4. **Given** I attempt to save an edit with an invalid amount (empty, zero, negative), **when** I tap Save, **then** the edit is rejected with a validation message and the original values remain unchanged until corrected.

**INVEST Notes**: Depends on US-02's field set; Testable via before/after budget recalculation checks.

---

### US-04: Delete Expense
**Phase**: MVP
**As a** user, **I want** to remove an expense I entered by mistake or no longer need, **so that** my records and budget stay accurate.

**Acceptance Criteria**:
1. **Given** an expense exists, **when** I delete it (via swipe-left or another delete action), **then** it is permanently removed and the relevant monthly budget's spend total decreases accordingly.
2. **Given** deleting an expense would drop the monthly budget below a previously-crossed notification threshold, **when** the deletion completes, **then** the budget display updates silently — no "threshold un-crossed" notification is sent (only crossing upward triggers notifications, per US-13).
3. **Given** I delete the last remaining expense in a given category for the month, **when** the deletion completes, **then** that category simply shows zero spend in reports/dashboard — the category itself is not deleted from the category list.
4. **Given** I initiate a delete action, **when** the action is destructive, **then** the app provides haptic feedback and/or a confirmation step before permanent removal (per PRD Section 11 UX Guidelines).

**INVEST Notes**: Small, independent; Testable via budget-recalculation assertions.

---

### US-05: Expense List Screen
**Phase**: MVP
**As a** user, **I want** to see all my expenses grouped by date with quick actions, **so that** I can review and manage my spending history efficiently.

**Acceptance Criteria**:
1. **Given** I open the Expense List screen, **when** the screen loads, **then** expenses are displayed grouped by date (most recent date group first), each card showing amount, category, description, expense type, date, and payment method.
2. **Given** an expense card is visible, **when** I swipe it left, **then** a delete action is triggered (per US-04); **when** I swipe it right, **then** an edit action is triggered (per US-03).
3. **Given** an expense card is visible, **when** I long-press it, **then** multi-select mode activates, allowing selection of multiple expenses for a bulk action (e.g., bulk delete).
4. **Given** the list contains a very large number of expenses (up to and beyond 500,000 records per NFR-2), **when** I scroll the list, **then** scrolling remains smooth (no visible jank) via pagination or lazy loading.
5. **Given** there are zero expenses recorded yet, **when** I open the Expense List screen, **then** an empty-state message is shown instead of a blank screen.

**INVEST Notes**: Valuable on its own; Testable via swipe-gesture and large-dataset scroll-performance checks.

---

### US-06: Manage Categories (Default + Custom)
**Phase**: MVP (default categories) / Productivity (custom category creation with icon/color picker)
**As a** user, **I want** to organize expenses into categories, including ones I define myself, **so that** my spending breakdown matches how I actually think about my money.

**Acceptance Criteria**:
1. **Given** a fresh install, **when** the app is first seeded, **then** all 13 default categories (Food, Groceries, Fuel, Utilities, Shopping, Medical, Education, Travel, Entertainment, Investment, Rent, Gifts, Others) are available for selection. *(MVP)*
2. **Given** I want a category not in the default list, **when** I create a custom category, **then** I can choose a name, an icon, and a color, and the new category becomes selectable everywhere other categories appear (Add Expense, filters, reports). *(Productivity)*
3. **Given** I attempt to create a custom category with a name matching an existing category (default or custom), **when** I save, **then** the app rejects the duplicate with a validation message. *(Productivity)*
4. **Given** a custom category has expenses assigned to it, **when** I attempt to delete that category, **then** the app either blocks deletion or prompts for how to reassign/orphan those existing expenses (design decision flagged for Functional Design). *(Productivity)*

**INVEST Notes**: Split across phases since default vs. custom categories are genuinely different scopes of work.

---

### US-07: Search Expenses
**Phase**: Analytics
**As a** user, **I want** to search my expenses by description, category, tag, or payment method, **so that** I can quickly find a specific transaction.

**Acceptance Criteria**:
1. **Given** I am on the Expense List (or a dedicated search view), **when** I type a search term, **then** results update instantly (per PRD Section 11 "Instant search") and match against description, category name, tags, and payment method.
2. **Given** my search term matches no expenses, **when** results are displayed, **then** an empty-results state is shown (not a blank/error screen).
3. **Given** I clear the search field, **when** the field becomes empty, **then** the full expense list is restored.

**INVEST Notes**: Independent of filtering (US-08) though often used together; Testable via instant-match assertions.

---

### US-08: Filter Expenses
**Phase**: Analytics
**As a** user, **I want** to filter my expense list by month, year, date range, category, expense type, payment method, or amount range, **so that** I can narrow down to exactly the transactions I care about.

**Acceptance Criteria**:
1. **Given** I apply a single filter (e.g., category = "Food"), **when** the filter is applied, **then** only matching expenses are shown.
2. **Given** I apply multiple filters simultaneously (e.g., category + date range + expense type), **when** all filters are active, **then** results satisfy all filter conditions (AND logic).
3. **Given** an amount-range filter with a minimum greater than the maximum, **when** I attempt to apply it, **then** the app prevents the invalid range or auto-corrects it with a message.
4. **Given** active filters yield zero results, **when** results are displayed, **then** an empty-state message is shown along with an option to clear filters.

**INVEST Notes**: Testable via combinatorial filter assertions; complements US-07 without depending on it.

---

### US-09: Sort Expenses
**Phase**: Analytics
**As a** user, **I want** to sort my expense list, **so that** I can see my biggest expenses or most recent activity first.

**Acceptance Criteria**:
1. **Given** the Expense List is displayed, **when** I choose "Newest First," "Oldest First," "Highest Amount," or "Lowest Amount," **then** the list re-orders accordingly and the choice persists while filters/search remain applied.
2. **Given** two expenses have identical amounts (for amount-based sorts) or identical dates (for date-based sorts), **when** sorted, **then** a stable, deterministic secondary order is applied (e.g., by ID) so the list doesn't visibly jitter on refresh.

**INVEST Notes**: Small, orthogonal to US-07/US-08; easily testable in isolation.

---

## Epic: Dashboard

### US-10: Dashboard Overview
**Phase**: MVP
**As a** user, **I want** a single screen summarizing my financial status, **so that** I immediately understand where I stand each time I open the app.

**Acceptance Criteria**:
1. **Given** onboarding is complete, **when** I open the app, **then** the Dashboard is the first screen shown, displaying: greeting, current month, monthly budget card, budget progress indicator, Personal vs Home summary, category breakdown chart, monthly spending trend graph, recent expenses, and a quick-add button.
2. **Given** no expenses have been logged yet this month, **when** the Dashboard loads, **then** budget/spend figures show ₹0 spent and 0% utilized rather than an error or blank chart.
3. **Given** I tap the quick-add button, **when** the tap registers, **then** I am taken directly to the Add Expense screen (US-02).
4. **Given** the current month changes (e.g., app opened on the 1st of a new month), **when** the Dashboard loads, **then** it reflects the new month's budget and resets spend calculations for that month, while historical months remain accessible via Reports.

**INVEST Notes**: Aggregates data from other epics but is independently testable via mocked/seeded data states.

---

## Epic: Budgeting

### US-11: Configure Monthly Budget
**Phase**: MVP
**As a** user, **I want** to set a monthly budget, either combined or split by ledger, **so that** I can track my spending against a target.

**Acceptance Criteria**:
1. **Given** I am in Budget settings, **when** I set a single combined monthly budget amount (the default mode), **then** it applies across both Personal and Home ledgers together.
2. **Given** I am in Budget settings, **when** I opt into separate per-ledger budgets, **then** I can set independent amounts for Personal and Home, each tracked and displayed independently.
3. **Given** a new month begins, **when** the app detects the month rollover, **then** a new budget period starts using the same configured amount(s) as the previous month, with $0 spent, unless I change it.
4. **Given** I attempt to set a budget amount of zero or negative, **when** I save, **then** the app rejects the value with a validation message.

**INVEST Notes**: Directly implements requirements.md FR-3.2; Testable via combined-vs-split mode switching.

---

### US-12: Budget Threshold Notifications
**Phase**: Analytics
**As a** user, **I want** to be notified when my spending approaches or exceeds my budget, **so that** I can adjust my spending before it's too late.

**Acceptance Criteria**:
1. **Given** I have enabled one or more thresholds (50%, 75%, 90%, 100%) in Budget settings, **when** cumulative spend for the current month crosses an enabled threshold (via a new expense), **then** a local notification fires immediately, referencing the threshold crossed.
2. **Given** a threshold has already fired this month, **when** I edit or delete an existing expense (not add a new one) in a way that recalculates the budget percentage, **then** no new notification fires for that same threshold this month, even if the percentage still shows at or above it (silent recalculation rule, Q6 Answer A).
3. **Given** spend drops below a previously-fired threshold (e.g., via a deletion) and then a *new* expense pushes it back over that same threshold, **when** that new expense is saved, **then** no notification re-fires for that threshold within the same month (thresholds fire at most once per month per threshold, regardless of how the crossing happens).
4. **Given** all notification thresholds are disabled in settings, **when** spending crosses 100% of budget, **then** no notification is sent.
5. **Given** the device has no network connectivity, **when** a threshold is crossed, **then** the notification still fires (local notifications only, per NFR-3).

**INVEST Notes**: Directly encodes the Q6 business-rule decision; Testable via scripted sequences of add/edit/delete crossing thresholds.

---

### US-13: Budget Screen
**Phase**: MVP (core display) / Analytics (budget history)
**As a** user, **I want** a dedicated screen showing my budget details and history, **so that** I can review how my spending compares to my budget over time.

**Acceptance Criteria**:
1. **Given** I open the Budget screen, **when** it loads, **then** I see monthly budget amount(s), amount spent, remaining budget, and a budget progress indicator, matching the mode (combined or per-ledger) configured in US-11. *(MVP)*
2. **Given** I am on the Budget screen, **when** I tap into notification settings, **then** I can toggle the 50/75/90/100% thresholds from US-12. *(MVP)*
3. **Given** I am on the Budget screen, **when** I view budget history, **then** I see a record of past months' budget amounts vs. actual spend. *(Analytics)*

**INVEST Notes**: Split into MVP display vs. Analytics history to match PRD phase boundaries.

---

## Epic: Reporting

### US-14: Monthly Spending Report
**Phase**: Analytics
**As a** user, **I want** to see total spending per month, **so that** I can track my overall spending trend.

**Acceptance Criteria**:
1. **Given** I open the Monthly Spending report, **when** it loads, **then** I see total expenses for each of the past N months (chart + values), including months with zero spend shown as ₹0 rather than omitted.
2. **Given** I filter the report to Personal-only, Home-only, or Combined, **when** I switch views, **then** the totals recalculate accordingly (per requirements.md FR-2.2).

---

### US-15: Category Analysis Report
**Phase**: Analytics
**As a** user, **I want** to see spending grouped by category, **so that** I know where my money goes.

**Acceptance Criteria**:
1. **Given** I open the Category Analysis report for a selected month, **when** it loads, **then** a pie chart and/or list shows each category's share of total spend for that month.
2. **Given** a category has zero spend in the selected period, **when** the chart renders, **then** that category is either omitted or shown at 0% without breaking the chart's layout/legend.
3. **Given** I have both default and custom categories with data, **when** the report renders, **then** custom categories display with their configured icon/color (US-06).

---

### US-16: Personal vs Home Comparison Report
**Phase**: Analytics
**As a** user, **I want** to compare my Personal and Home spending, **so that** I understand the balance between the two.

**Acceptance Criteria**:
1. **Given** I open the Personal vs Home report for a selected period, **when** it loads, **then** I see a side-by-side or combined comparison of total spend per ledger.
2. **Given** one ledger has zero expenses in the period, **when** the report renders, **then** it shows ₹0 for that ledger rather than erroring.

---

### US-17: Top Spending Categories Report
**Phase**: Analytics
**As a** user, **I want** to see my highest-spending categories ranked, **so that** I can identify where to cut back.

**Acceptance Criteria**:
1. **Given** I open the Top Spending Categories report, **when** it loads, **then** categories are ranked descending by total spend for the selected period.
2. **Given** two categories have identical totals, **when** ranked, **then** a stable, deterministic tie-breaking order is applied.

---

### US-18: Monthly Comparison Report
**Phase**: Analytics
**As a** user, **I want** to compare this month's spending against previous months, **so that** I can see if I'm improving or regressing.

**Acceptance Criteria**:
1. **Given** I open the Monthly Comparison report, **when** it loads, **then** the current month's total is shown alongside one or more prior months, with a visual indicator of increase/decrease.
2. **Given** this is the user's first month of data (no prior months exist), **when** the report loads, **then** it gracefully shows only the current month without erroring on missing historical data.

---

### US-19: Budget Utilization Report
**Phase**: Analytics
**As a** user, **I want** to see what percentage of my budget I've used, **so that** I can gauge my spending pace.

**Acceptance Criteria**:
1. **Given** I open the Budget Utilization report, **when** it loads, **then** it shows percentage of budget consumed for the selected period, consistent with the figures shown on the Dashboard (US-10) and Budget screen (US-13).
2. **Given** spend exceeds 100% of budget, **when** the report renders, **then** it clearly indicates over-budget status (e.g., >100%, visually distinct color) rather than capping the display at 100%.

---

## Epic: Backup & Data Portability

### US-20: Manual and Automatic Backup & Restore
**Phase**: Productivity
**As a** user, **I want** my data backed up automatically and restorable on demand, **so that** I don't lose my financial history if my device is lost or damaged.

**Acceptance Criteria**:
1. **Given** the app is installed and in use, **when** a scheduled nightly backup runs, **then** a backup (database, settings, categories) is silently written to app-private local storage without requiring user action (FR-8.2, NFR-6).
2. **Given** I manually trigger "Backup" in Settings, **when** the backup completes, **then** a ZIP archive containing the database, settings, and categories is created at a user-chosen or app-designated local location.
3. **Given** I have a valid backup ZIP file, **when** I trigger "Restore" and select that file, **then** my database, settings, and categories are replaced with the backup's contents, and the app confirms success before/after the operation.
4. **Given** I attempt to restore from a corrupted or invalid backup file, **when** the restore is attempted, **then** the app fails safely — showing a clear error and leaving the existing data untouched (no partial/corrupted overwrite).
5. **Given** automatic nightly backups accumulate over time, **when** storage is managed, **then** old backups are pruned per a defined retention policy (exact policy to be defined in Functional/NFR Design).

**INVEST Notes**: Encodes the requirements.md backup decision (nightly + manual); fail-safe restore behavior ties to Security Baseline SECURITY-13/15.

---

### US-21: Export Data
**Phase**: Productivity
**As a** user, **I want** to export my expense data in common formats, **so that** I can use it outside the app (e.g., for taxes or personal analysis).

**Acceptance Criteria**:
1. **Given** I choose "Export" in Settings, **when** I select CSV, Excel, or JSON, **then** a file containing my expense data is generated in that format and saved to a location I can access or share.
2. **Given** I have applied filters on the Expense List (US-08), **when** I export from that filtered context (if supported), **then** the export reflects only the filtered data — otherwise the export always covers all data and this is clearly communicated (design decision flagged for Functional Design).
3. **Given** an export operation fails (e.g., insufficient storage), **when** the failure occurs, **then** the app shows a clear error message and does not leave a partially-written, corrupted export file.

---

## Epic: Settings

### US-22: App Settings
**Phase**: Productivity
**As a** user, **I want** a central place to configure the app, **so that** I can tailor it to my preferences.

**Acceptance Criteria**:
1. **Given** I open Settings, **when** the screen loads, **then** I can change Theme (Dark/Light/System), Currency, Notification Preferences, and access Backup & Restore, Export Data, and About.
2. **Given** I change the Theme, **when** the change is applied, **then** the entire app (Dashboard, Expense List, Reports, etc.) immediately reflects the new theme without requiring an app restart.
3. **Given** I change the Currency, **when** the change is applied, **then** all monetary displays across the app update to the new currency symbol/formatting (existing amounts are not converted — only the display symbol/format changes, since this is a single-currency app per PRD scope).

---

## Epic: Premium Experience (Polish)

### US-23: Smooth Animations and Material 3 Polish
**Phase**: Premium Experience
**As a** user, **I want** the app to feel modern and responsive, **so that** using it daily feels pleasant rather than utilitarian.

**Acceptance Criteria**:
1. **Given** I navigate between screens, **when** transitions occur, **then** they are smooth page transitions at 60 FPS (NFR-1), using rounded Material 3 cards and elegant typography (PRD Section 11).
2. **Given** charts are displayed (Reports, Dashboard), **when** they first render or update, **then** they animate smoothly rather than snapping instantly to final values.
3. **Given** I perform a destructive action (e.g., delete), **when** the action is confirmed, **then** haptic feedback is triggered (per PRD Section 11).

---

### US-24: Accessibility Improvements
**Phase**: Premium Experience
**As a** user (including one relying on accessibility features), **I want** the app to be usable with larger text, screen readers, and sufficient contrast, **so that** the app remains usable regardless of my visual needs.

**Acceptance Criteria**:
1. **Given** Android system font scaling is increased, **when** I view any screen, **then** text scales appropriately without truncation or overlapping elements.
2. **Given** I use a screen reader (e.g., TalkBack), **when** I navigate the app, **then** interactive elements (buttons, cards, inputs) have meaningful accessible labels.
3. **Given** Dark Mode or Light Mode is active, **when** any screen renders, **then** text-to-background contrast meets standard accessibility contrast ratios.

---

## Persona-to-Story Mapping

All 24 stories map to the single persona, **The Privacy-Conscious Budget Owner** (see [personas.md](personas.md)) — there is no secondary persona in this app.

## Phase Summary

| Phase | Stories |
|---|---|
| MVP | US-01, US-02, US-03, US-04, US-05, US-06 (default categories only), US-10, US-11, US-13 (core display) |
| Analytics | US-07, US-08, US-09, US-12, US-13 (history), US-14, US-15, US-16, US-17, US-18, US-19 |
| Productivity | US-06 (custom categories), US-20, US-21, US-22 |
| Premium Experience | US-23, US-24 |
