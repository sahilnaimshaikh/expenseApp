import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared page-transition builder (Unit 7, US-23) — one fade-through
/// transition reused by every pushed route, per nfr-design-patterns.md's
/// "Consistent transition pattern". Applied to routes that push on top of
/// the bottom-nav shell (Add/Edit Expense, Budget) rather than the shell's
/// own tab switches, which use IndexedStack's instant swap by design.
CustomTransitionPage<T> fadeThroughPage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}
