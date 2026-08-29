# Domain Entities — Unit 6: Backup, Export & Settings

No new persistent entities. Consumes all 4 of Unit 1's collections for backup assembly/restore and export.

## BackupManifest (transient, describes a backup archive's contents)

| Field | Type |
|---|---|
| createdAt | DateTime |
| appVersion | String |
| expenseCount | int |
| categoryCount | int |
| budgetCount | int |

**Purpose**: Written as `manifest.json` inside the backup ZIP so `restoreFromBackup` can validate a file is a genuine, compatible backup before attempting to parse the rest of the archive (fail-safe restore, per stories.md US-20 AC4).

## ExportFormat (enum, transient)
`csv`, `excel`, `json`
