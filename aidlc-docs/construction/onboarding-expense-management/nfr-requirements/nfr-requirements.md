# NFR Requirements — Unit 2: Onboarding & Expense Management

Decided directly (autonomous mode), consistent with Unit 1's established posture.

## Performance
- **NFR-1 traceability ("lightning fast")**: Add Expense screen must render and accept input within one frame of navigation; Save must complete and navigate away within ~300ms perceived latency for typical (non-500k-scale) data volumes — Isar writes are synchronous-feeling for single-row inserts, so no additional optimization is needed at this unit's scope.
- Expense List must render its first visible page without blocking on the full 500,000-row dataset — achieved via `ExpenseRepository.query()`'s existing `limit`/`offset` support (Unit 1), consumed here with an initial page size of 50.

## Reliability
- RESILIENCY-01: Add/Edit/Delete Expense flows are classified **Critical** (same as Unit 1's data classification — this unit is the primary write path for that critical data).
- BR-13 (bulk-delete transactionality) is this unit's data-integrity contribution, consistent with Unit 1's BR-6 pattern.

## Security
Same rule-by-rule status as Unit 1 (SECURITY-01 partial/OS-level, 02/04/05/06/07/08/12/14 N/A, 03/09/10/11/13/15 apply) — no new considerations introduced by this unit; ExpenseInput validation (BR-10) is this unit's SECURITY-05 analog (input validation, enforced at the service layer since there's no API boundary).

## Maintainability
- `ExpenseInput`/`OnboardingInput` DTOs are introduced specifically so `ExpenseService`/`SettingsService` method signatures don't need to change every time a new optional field is added to the Add Expense form — extending the form only requires adding a field to the DTO, not touching the repository/service contract.

## Usability
- Onboarding must be completable in under 1 minute for a user who accepts all defaults (currency=INR, skip budget) — directly supports the PRD's "effortless" design philosophy (Section 7).
- Add Expense's required-field set (amount, category, type) must be reachable via numeric keypad + two taps, consistent with the Q7 "lightning fast" decision from Application Design.

## Tech Stack
No new dependencies — this unit consumes Riverpod, Go Router (for screen navigation, added now since this is the first unit with actual screens), and Flutter's built-in Material widgets. No PBT framework changes (still `glados`, per Unit 1).
