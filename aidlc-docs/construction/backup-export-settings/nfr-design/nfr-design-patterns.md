# NFR Design Patterns — Unit 6: Backup, Export & Settings

## Reliability Patterns
- **Validate-before-mutate pattern** (BR-29): restore never touches Isar until the manifest is fully validated.
- **Temp-then-move pattern** (BR-31): all file-producing operations (backup ZIP, CSV/Excel/JSON export) write to a temp path first, moving to the final destination only on success.
- **Bounded automatic retention pattern** (BR-28): nightly backups self-prune to the most recent 7, preventing unbounded storage growth without any user action.

## Security Patterns
- **Generic restore-failure messaging pattern**: consistent with Unit 1's RepositoryException pattern — internal parse/ZIP errors are logged, never surfaced verbatim to the UI.

## Logical Components
- **BackgroundTaskScheduler** (via `workmanager`): registers the nightly backup job at app startup. New logical component this unit introduces.
- **BackupService, ExportService**: new domain services, per Application Design's Q6 decision (kept separate).
