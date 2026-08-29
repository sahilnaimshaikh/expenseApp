# Resiliency Baseline - Follow-Up Questions

You opted in to the **Resiliency Baseline** extension. Its rule set (RESILIENCY-01 through 15) is written for deployed, cloud-hosted, multi-instance workloads. This app is a fully offline, single-device Flutter app with no backend, no cloud infrastructure, and no multi-user deployment target.

Before finalizing requirements, I need to:
1. Ask the one question that has a real local-app analog (data-loss tolerance / backup expectations).
2. Confirm which rules are genuinely N/A for this project so they aren't treated as blocking findings later.

## Question 1: Data-Loss Tolerance / Backup Expectations (RESILIENCY-02 & RESILIENCY-12 analog)
Since there's no server, "RTO/RPO" doesn't apply in the cloud sense — but data-loss tolerance still matters: if the user's phone is lost, damaged, or the app's local database becomes corrupted, how much expense history are they willing to risk losing, and how should backups work?

A) Manual backups only — user must remember to tap "Backup" in Settings; no automatic reminders. Acceptable to lose data since the last manual backup.

B) Automatic periodic local backup reminders (e.g., app prompts "Back up now?" weekly or after N new expenses) plus manual backup-on-demand, still exported to a user-chosen location (no cloud).

C) Automatic silent local backup on a schedule (e.g., nightly) to app-private storage, in addition to manual export — minimizes data loss without requiring user action, still fully offline/on-device.

X) Other (please describe after [Answer]: tag below)

[Answer]: C)

## Question 2: Confirm N/A Determinations
Based on this app having no backend, no cloud infrastructure, and running on a single user's device, I'm proposing the following RESILIENCY rules be marked **N/A** for this project (not blocking findings): RESILIENCY-03 (change management process), RESILIENCY-04 (CI/CD & rollback), RESILIENCY-05 (monitoring/observability dashboards), RESILIENCY-06 (health checks), RESILIENCY-07 (resiliency posture monitoring), RESILIENCY-08 (multi-zone/multi-region), RESILIENCY-09 (auto-scaling), RESILIENCY-10 (circuit breaking/dependency isolation), RESILIENCY-11 (cloud DR strategy selection), RESILIENCY-13 (failover runbooks), RESILIENCY-14 (chaos engineering/DR testing), RESILIENCY-15 (incident response process). Do you agree?

A) Yes — mark all listed rules N/A as proposed; only RESILIENCY-01 (criticality of the local data), RESILIENCY-02/12 analog (Question 1 above), and general local-data-integrity practices (crash-safe writes, atomic file operations for backup/restore) apply.

B) No — I want some of the listed rules still considered (specify which, and how, after [Answer]: tag below)

X) Other (please describe after [Answer]: tag below)

[Answer]: A)
