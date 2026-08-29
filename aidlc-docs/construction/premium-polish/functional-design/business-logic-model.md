# Business Logic Model — Unit 7: Premium Polish

## Overview
Per unit-of-work.md, this unit introduces **no new components** — it applies cross-cutting UI/UX refinement to all prior units' presentation layers. There are no new business rules (BR-numbered) since there's no new business logic; the design decisions here are UI/UX-only.

## Scope (US-23, US-24)

### Animations & Material 3 Polish (US-23)
- Page transitions: Go Router supports custom `pageBuilder` transitions; apply a consistent fade-through transition across all routes.
- Chart animations: `fl_chart`'s `PieChartData`/`LineChartData` support `swapAnimationDuration` — enable on Dashboard and Reports charts (currently instant, per Units 4/5's initial implementation).
- Rounded Material 3 cards: audit all `Card` widgets across Units 2-6 for consistent `shape: RoundedRectangleBorder` and elevation, per PRD Section 11.
- Haptic feedback: add `HapticFeedback.mediumImpact()` to all destructive actions (delete expense, delete category) — currently missing from Units 2 and 6.

### Accessibility (US-24)
- Text scaling: audit fixed-size `Text` widgets for hardcoded font sizes that won't respond to `MediaQuery.textScaler` — none currently found in generated code (all use `Theme.of(context).textTheme.*` or default styles, which do scale), but flagged for verification during Build and Test on-device testing.
- Screen reader labels: add `Semantics` labels to icon-only buttons (e.g., the multi-select delete `IconButton`, sort `PopupMenuButton`) across Units 2, 3, 5.
- Contrast: rely on Material 3's `colorSchemeSeed`-generated color scheme, which is contrast-validated by Flutter's Material 3 implementation — no manual contrast overrides introduced elsewhere in the app that would need separate validation.

## Error Scenarios
None — this unit has no business logic, hence no new error paths.

## Frontend Components
No new screens. Modifications only, to existing components across Units 2, 3, 4, 5, 6:
- `expense_list_screen.dart` — haptic feedback on delete, Semantics on icon buttons
- `dashboard_screen.dart`, `reports_screen.dart` — chart animation duration
- `budget_screen.dart`, `settings_screen.dart` — haptic feedback on delete actions
- `app_router.dart` — consistent page transition
