# NFR Requirements — Unit 6: Backup, Export & Settings

## Reliability
- RESILIENCY-01/02/12 (local-data analog, from requirements.md): this unit directly implements the previously-decided automatic nightly backup + manual export strategy. BR-29's validate-before-mutate restore and BR-31's temp-then-move export are this unit's concrete fulfillment of "crash-safe, atomic file operations for backup/restore" flagged in requirements.md NFR-6.

## Security
| Rule | Status | Notes |
|---|---|---|
| SECURITY-13 (data integrity) | Applies | Backup/restore is exactly the "safe backup/restore deserialization" scenario flagged in requirements.md — manifest validation (BR-29) is the deserialization-safety gate |
| SECURITY-01 (encryption) | Partial | Backup ZIP files are NOT separately encrypted beyond the OS-level File-Based Encryption already relied upon (Unit 1's determination) — if a user exports to external/shared storage, that file is no longer protected by app-private encryption. Flagged as a known trade-off, not silently ignored: the Export/Backup screens should show a brief note that exported files are unencrypted. |
| SECURITY-09 (hardening) | Applies | Restore failure messages must stay generic — never expose raw ZIP/JSON parse exceptions to the end user |

## Performance
- Backup/export of the full dataset must handle 500,000+ Expense rows without exhausting memory — batched writes (not one giant in-memory JSON string) if performance profiling later reveals it's needed; for this pass, straightforward full-collection fetch + serialize is used, flagged for revisit if profiling (Build and Test stage) shows memory pressure at scale.

## Tech Stack
`archive` (ZIP), `csv`, `excel`, `share_plus` (share the exported file), `file_picker` (restore/browse), `flutter_colorpicker` (BR-32's color picker), `workmanager` (Android background task scheduling for the nightly backup) — all already pinned in pubspec.yaml since Unit 1's dependency planning.
