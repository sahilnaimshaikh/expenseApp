# Personas — Expense Tracker

Per the approved story plan ([story-generation-plan.md](../plans/story-generation-plan.md), Question 1, Answer A), this app is modeled with a **single persona**. The app is explicitly single-user with no accounts or multi-user sync (PRD Section 12); the Personal/Home ledger split represents *categories of the same person's spending*, not different people.

## Persona: The Privacy-Conscious Budget Owner

**Name (illustrative)**: Aditya Sharma
**Role**: Sole user of the app — manages both their own personal spending and their household's shared expenses.

### Characteristics
- Uses an Android phone as their primary computing device for personal finance.
- Comfortable with mobile apps, but has no interest in creating accounts, syncing to the cloud, or paying subscriptions for a finance app.
- Pays for things via a mix of Cash, UPI, Debit Card, Credit Card, and Bank Transfer (India-based, INR as default currency).
- Sometimes logs expenses on the go (right after a purchase) and sometimes catches up on several at once (e.g., reviewing card statements).
- Occasionally shares "household" costs (rent, utilities, groceries) that are conceptually separate from personal discretionary spending, hence the need for Personal vs. Home ledgers — but there is only one person operating the app.

### Goals
- Record an expense in as few taps as possible, without breaking their flow.
- Always know, at a glance, how much of this month's budget is left.
- Understand where their money actually goes (categories, Personal vs. Home split, trends over time) without manually building a spreadsheet.
- Get nudged (via notification) before overspending, not after.
- Never worry about losing their financial history to a lost/broken phone, without needing a cloud account.
- Occasionally export data (e.g., for tax purposes or personal analysis) without proprietary lock-in.

### Frustrations (with existing alternatives)
- Cloud-based expense apps require account creation, subscriptions, or expose personal financial data to third-party servers.
- Many apps make simple expense entry slow (too many required fields, multi-screen flows).
- Generic "wallet" apps don't distinguish personal vs. shared household spending, making budgeting confusing.
- Apps that require internet connectivity to function are unreliable when offline (poor connectivity, airplane mode, data saving).

### Technical Comfort
- Comfortable installing apps and using standard Android gestures (swipe, long-press).
- Not a developer or power user of finance tools — expects sensible defaults (e.g., pre-seeded categories, INR default currency, guided onboarding for the first budget) rather than needing to configure everything manually.
- Will use Settings to adjust currency, theme, and notification thresholds when their needs diverge from defaults.

### Relationship to Requirements
This single persona is the intended user for every story in [stories.md](stories.md) — there is no secondary/admin/family-member persona, consistent with the PRD's single-user, offline-first design (PRD Sections 4, 12).
