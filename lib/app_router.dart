import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/budgeting/presentation/budget_screen.dart';
import 'features/dashboard/presentation/app_shell.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/expense_management/presentation/add_edit_expense_screen.dart';
import 'features/expense_management/presentation/expense_list_screen.dart';
import 'features/onboarding/domain/onboarding_providers.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/reporting/presentation/reports_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'shared/page_transitions.dart';

/// Single app-wide router. Extended by every later unit as new screens are
/// added (per nfr-design-patterns.md "GoRouter instance" logical
/// component) — do not create a second GoRouter instance in a later unit.
///
/// Uses a [StatefulShellRoute] (introduced in Unit 4) for the 4 bottom-nav
/// tabs (Dashboard/Expenses/Reports/Settings, per PRD Section 8), each tab
/// keeping its own navigation stack so switching tabs doesn't lose state.
/// As of Unit 6, all 4 tabs use their real screens — no placeholders
/// remain.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final settingsService = await ref.read(settingsServiceProvider.future);
      final onboardingComplete = await settingsService.isOnboardingComplete();

      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!onboardingComplete && !goingToOnboarding) return '/onboarding';
      if (onboardingComplete && goingToOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/expenses',
              builder: (context, state) => const ExpenseListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  pageBuilder: (context, state) =>
                      fadeThroughPage(child: const AddEditExpenseScreen(), state: state),
                ),
                GoRoute(
                  path: 'edit/:id',
                  pageBuilder: (context, state) => fadeThroughPage(
                    child: AddEditExpenseScreen(editingId: int.parse(state.pathParameters['id']!)),
                    state: state,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/budget',
        pageBuilder: (context, state) => fadeThroughPage(child: const BudgetScreen(), state: state),
      ),
    ],
  );
});
