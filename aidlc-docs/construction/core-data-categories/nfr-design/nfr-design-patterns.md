# NFR Design Patterns — Unit 1: Core Data & Categories

Decided directly (autonomous mode) from [nfr-requirements.md](../nfr-requirements/nfr-requirements.md).

## Resilience Patterns
- **Transactional write pattern**: All multi-row mutations (category deletion + expense reassignment, BR-6) wrapped in `isar.writeTxnSync()` / `writeTxn()` — atomic commit or full rollback, no partial state ever observable.
- **Fail-safe repository pattern**: Every repository method wraps its Isar call in try/catch, rethrowing as `RepositoryException` (BR-8) — callers always get a typed, catchable failure, never a silent null or an unhandled platform exception.

## Scalability Patterns
- **Indexed query pattern**: All query methods route through Isar's indexed fields (see tech-stack-decisions.md) rather than in-memory filtering of full table scans — critical at 500,000+ row scale.
- **Streaming reads pattern**: `watchAll()`/reactive queries use Isar's native `Stream` support rather than manual polling, so UI updates are push-based and don't require re-querying on a timer.

## Performance Patterns
- **Lazy pagination pattern**: `ExpenseRepository.query()` accepts `limit`/`offset` (or Isar's `.offset().limit()` query builder) so later units can implement infinite-scroll lists without loading all 500,000+ rows into memory at once.

## Security Patterns
- **Generic error surface pattern**: `RepositoryException` messages shown to end users (via Riverpod `AsyncValue.error`) are generic ("Couldn't save your data — please try again"); the underlying Isar exception detail is logged internally only (SECURITY-09, SECURITY-15).
- **No-PII-in-logs pattern**: Logging statements in repositories/services log operation names and entity IDs, never expense description text, amounts, or full file paths (SECURITY-03).

## Logical Components
- **Isar instance provider**: A single Riverpod `Provider<Isar>` initializes the database once at app startup and is injected into all four repositories — no repository creates its own connection.
- **No queue/cache/circuit-breaker components needed**: This unit has no network calls, no distributed dependencies, and no concurrency contention beyond Isar's own internal locking — these patterns are explicitly N/A for a single-process local-database unit.
