import 'package:flutter/services.dart';

/// Shared haptic-feedback helper for destructive actions (delete expense,
/// delete category, bulk delete), per PRD Section 11 UX Guidelines
/// ("Haptic feedback for destructive actions") and Unit 7's
/// haptic-on-destructive pattern.
void triggerDestructiveHaptic() {
  HapticFeedback.mediumImpact();
}
