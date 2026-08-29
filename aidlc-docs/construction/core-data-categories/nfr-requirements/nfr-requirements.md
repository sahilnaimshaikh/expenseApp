# NFR Requirements — Unit 1: Core Data & Categories

## Scalability
- **NFR-2 traceability**: Repositories must efficiently support 500,000+ Expense records. Isar indexes are required on `Expense.date`, `Expense.categoryId`, `Expense.expenseType`, and `Expense.paymentMethod` to support the filter/sort operations later units (2, 5) will build on top of this repository layer.
- Query methods (`ExpenseRepository.query()`) must support pagination/limit parameters so later units can implement lazy-loading lists (stories.md US-05 AC4) without this unit needing to know about UI paging concerns.

## Performance
- Repository CRUD operations must complete without perceptible UI delay to support NFR-1 (app launch ≤2s, "lightning fast" expense entry). Isar's synchronous-feeling async API (backed by native code) is relied upon; no additional caching layer is added at this unit's scope.
- `watchAll()` / reactive query streams must be used (not polling) so presentation-layer controllers in later units can react to data changes efficiently.

## Availability / Reliability
- **RESILIENCY-01 (Critical Workload Identification)**: Expense, Budget, Category, and Settings data are classified **Critical** — irreplaceable personal financial history with no server-side backup; loss directly harms the user's ability to track their finances. This classification is the basis for Unit 6's backup strategy (already decided in requirements.md: automatic nightly local backup + manual export).
- **RESILIENCY-02/12 analog (local data-loss tolerance)**: Already resolved in requirements.md (automatic nightly local backup). This unit's obligation is to ensure writes are transactional (BR-6) so backups always capture a consistent state — never a partially-written one.
- All other RESILIENCY rules (03, 04, 05, 06, 07, 08, 09, 10, 11, 13, 14, 15) confirmed **N/A** for this unit — no backend, no cloud infrastructure, no deployed service, consistent with the project-wide determination in requirements.md.

## Security
| Rule | Status | Rationale |
|---|---|---|
| SECURITY-01 (Encryption at rest/in transit) | **Partial / N/A for app-level** | No in-transit concern (no network). At-rest: relies on Android's OS-level File-Based Encryption of app-private storage (default since Android 10) rather than adding an app-level Isar encryption dependency, which is immature/unstable for this Isar version. Documented as an accepted risk trade-off, not silently skipped. |
| SECURITY-02 (Access logging, network intermediaries) | N/A | No load balancers, gateways, or CDNs exist. |
| SECURITY-03 (Application-level logging) | Applies | Repository/service error logs must never include expense description text, amounts with identifying context, or full backup file paths that could leak user data into device logs. |
| SECURITY-04 (HTTP security headers) | N/A | No HTML-serving endpoints. |
| SECURITY-05 (Input validation on API params) | N/A (no APIs) — analog applies | The analog is enforced at the service layer (ExpenseService/CategoryService), documented in business-rules.md BR-1/BR-2/BR-7, not at this unit's repository layer. |
| SECURITY-06 (Least-privilege IAM) | N/A | No cloud IAM; local app has full access to its own private storage by OS design. |
| SECURITY-07 (Network configuration) | N/A | No network. |
| SECURITY-08 (Application-level access control) | N/A | Single-user app, no auth, no multi-tenant resource ownership concern. |
| SECURITY-09 (Hardening/misconfiguration) | Applies | Error responses (RepositoryException messages) must not leak Isar internal file paths or stack traces to end-user-facing UI; acceptable in developer logs only. |
| SECURITY-10 (Supply chain security) | Applies | `pubspec.lock` committed; Isar and all dependencies pinned to exact versions; sourced from pub.dev official registry only. |
| SECURITY-11 (Secure design principles) | Applies | Layered architecture (Data/Domain/Presentation) already satisfies separation-of-concerns for this rule. |
| SECURITY-12 (Auth/credential management) | N/A | No authentication in this app. |
| SECURITY-13 (Data integrity) | Applies | Transactional writes (BR-6) satisfy the data-integrity requirement; critical data changes (category deletion reassignment) are implicitly auditable via `updatedAt` timestamps on affected Expense rows. |
| SECURITY-14 (Alerting/monitoring) | N/A | No production alerting infrastructure for a local mobile app; no security events of the type this rule targets (auth failures, etc.) exist in this unit's scope. |
| SECURITY-15 (Exception handling, fail-safe defaults) | Applies | Directly implemented via BR-8 (typed RepositoryException, no silent failures, fail-closed on error). |

## Property-Based Testing (PBT-09 — Framework Selection for This Unit)
See [tech-stack-decisions.md](tech-stack-decisions.md) for the selected Dart PBT framework.

## Maintainability
- Repository and service interfaces (already defined in Application Design's component-methods.md) must remain stable as later units build on them — any breaking change to `ExpenseRepository`/`CategoryService` signatures requires updating this document and flagging impact on dependent units (per unit-of-work-dependency.md's cross-unit interface contracts).
- Every business rule in business-rules.md must have a corresponding example-based test AND, where a property was identified (PBT-01), a property-based test (PBT-10 complementary testing strategy).

## Usability
Not directly applicable — this unit has no UI (per functional design's Frontend Components note). Deferred to units that own presentation for these entities.
