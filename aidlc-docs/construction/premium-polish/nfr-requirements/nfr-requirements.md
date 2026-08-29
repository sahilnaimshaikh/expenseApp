# NFR Requirements — Unit 7: Premium Polish

## Performance
- NFR-1 (60 FPS): all added animations (page transitions, chart animations) must use Flutter's built-in animation curves/durations (200-400ms range) — no custom animation controllers introduced that could risk jank at scale.

## Usability / Accessibility
- WCAG-aligned contrast (implicitly satisfied via Material 3's seeded color scheme, per business-logic-model.md).
- Minimum tappable target size (48x48dp) — Material 3 widgets meet this by default; no custom small tap targets were introduced in any prior unit's code.

## Security / Reliability
No new considerations — this unit touches only presentation-layer polish, no data or business-logic changes.
