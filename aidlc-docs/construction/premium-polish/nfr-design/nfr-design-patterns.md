# NFR Design Patterns — Unit 7: Premium Polish

## UX Patterns
- **Consistent transition pattern**: one shared `CustomTransitionPage` builder function used by every route in `app_router.dart`, rather than per-route custom transitions — ensures visual consistency without duplicating transition logic.
- **Haptic-on-destructive pattern**: a single reusable helper (`triggerDestructiveHaptic()`) called from every delete confirmation across the app, rather than inlining `HapticFeedback` calls ad hoc in each screen.

## Logical Components
No new services. One new shared presentation-layer utility: a haptics helper function.
