# Tech Stack Decisions — Unit 2: Onboarding & Expense Management

## Go Router Setup (first unit with real navigation)
**Decision**: A single top-level `GoRouter` instance with named routes: `/onboarding`, `/` (Dashboard placeholder → Expense List for now), `/expense/add`, `/expense/edit/:id`. `redirect` logic checks `SettingsService.isOnboardingComplete()` to route first-launch users to `/onboarding`.
**Rationale**: Go Router is fixed by the PRD; this is simply its first concrete application. Declarative routing keeps the onboarding-redirect logic centralized rather than scattered across widget `initState` checks.

## Riverpod Notifier Pattern for Controllers
**Decision**: `OnboardingController`, `AddEditExpenseController`, and `ExpenseListController` are implemented as Riverpod `Notifier`/`AsyncNotifier` classes (not `StateNotifier`, which is soft-deprecated in favor of the newer `Notifier` API as of Riverpod 2.x).
**Rationale**: Matches the Riverpod version pinned in pubspec.yaml (2.5.1) and its recommended current API.

## Numeric Input Formatting
**Decision**: Amount input uses Flutter's `TextInputType.numberWithOptions(decimal: true)` with a custom `TextInputFormatter` restricting to 2 decimal places (matching the Q1 decimal-precision decision from Unit 1).
**Rationale**: Prevents users from ever entering an amount the decimal-safe arithmetic layer would need to silently truncate.
