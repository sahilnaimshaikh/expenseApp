# NFR Design Patterns — Unit 2: Onboarding & Expense Management

## Performance Patterns
- **Paginated list pattern**: `ExpenseListController` requests pages of 50 via `ExpenseRepository.query(limit: 50, offset: page*50)`, appending to its in-memory list as the user scrolls (infinite scroll), rather than loading all rows.
- **Optimistic UI pattern**: On Save, the Add Expense form immediately navigates back and shows the new expense in the list optimistically; if the underlying `ExpenseService.addExpense` call fails, a snackbar error appears and the optimistic entry is rolled back. Chosen to make Save feel instantaneous (NFR-1) even though Isar writes are already fast — this removes any perceived wait entirely.

## Reliability Patterns
- **Transactional bulk-delete pattern**: `ExpenseService.deleteMany` wraps all deletes in one `isar.writeTxn()` (BR-13), reusing Unit 1's transactional-write pattern.

## Security Patterns
- **Service-layer validation gate pattern**: All `ExpenseInput`/`OnboardingInput` values pass through `ExpenseService`/`SettingsService` validation (BR-10) before ever reaching a repository — no UI widget is trusted to be the sole enforcement point, consistent with defense-in-depth (SECURITY-11).

## Logical Components
- **GoRouter instance**: One app-wide router, redirect-gated on onboarding completion.
- **No new infrastructure components**: consistent with Unit 1's determination — no queues, caches, or circuit breakers needed for a local-only app.
