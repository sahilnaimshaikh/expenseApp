# NFR Requirements Plan — Unit 1: Core Data & Categories

Per user instruction, NFR questions for this unit are decided directly (tech stack is already fixed by requirements.md/PRD, and no genuine open business decisions remain for this unit's scope). Decisions and rationale are documented below and carried into the generated artifacts.

## Execution Checklist
- [x] Step 1: Analyze functional design artifacts (domain-entities.md, business-rules.md, business-logic-model.md)
- [x] Step 2: Decide NFR posture across scalability, performance, security, reliability, maintainability
- [x] Step 3: Decide tech-stack specifics scoped to this unit (indexing strategy, PBT framework for Dart, dependency management)
- [x] Step 4: Generate `nfr-requirements.md`
- [x] Step 5: Generate `tech-stack-decisions.md`
- [ ] Step 6: Present for review and approval

## Decisions

- **Scalability**: Isar indexes added on Expense (`date`, `categoryId`, `expenseType`, `paymentMethod`) and a composite unique index on Budget (`month`, `year`, `ledgerScope`) and Category (`name`, case-insensitive unique) — directly supports NFR-2 (500,000+ records) and enforces BR-1/Budget uniqueness at the DB level as a second line of defense behind service-layer checks.
- **Performance**: Isar's native query performance (sub-millisecond for indexed lookups) is relied upon to meet NFR-1 (2s launch) — no additional caching layer needed at this unit's scale; repository query methods return `Future`/`Stream` to support reactive, non-blocking UI per Q4 from Application Design.
- **Security**: SECURITY-01 (encryption at rest) resolved as N/A for app-level DB encryption — Isar has no mature native encryption in the version used, and Android's File-Based Encryption (default since Android 10, i.e. within this app's practical deployment target) already encrypts app-private storage at the OS level. This is documented as the resolution rather than adding an unstable app-level encryption dependency. SECURITY-03 (structured logging, no PII) and SECURITY-15 (fail-safe error handling, BR-8) apply directly. SECURITY-02/04/05/06/07/08/12/14 confirmed N/A (no network, no auth, no cloud IAM). SECURITY-10 (supply chain) applies: `pubspec.lock` committed, exact Isar/dependency versions pinned.
- **Reliability**: RESILIENCY-01 — Expense/Budget/Category/Settings data classified **Critical** (irreplaceable personal financial history, no server-side copy). Isar's transactional writes (BR-6) plus this classification feed directly into Unit 6's backup/restore design. All other Resiliency rules remain N/A per the determination already confirmed in requirements.md.
- **Maintainability**: Property-Based Testing framework selected below (PBT-09).
- **Tech stack**: No new choices — Isar, Riverpod, Dart remain as fixed by requirements.md. The only unit-specific tech decision is the PBT framework for Dart (not in the extension's example table), resolved below.
