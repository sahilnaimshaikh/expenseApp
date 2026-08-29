import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'features/backup_export/domain/background_backup_task.dart';
import 'features/notifications/domain/notification_providers.dart';

/// App entry point. Real navigation (Go Router) is wired up starting Unit 2
/// (Onboarding & Expense Management) — see app_router.dart. Notification
/// channel setup (Unit 3) and nightly-backup task registration (Unit 6)
/// happen once here, before the first frame.
void main() {
  // Fire-and-forget: registration failures must not block app startup
  // (fail-safe pattern, consistent with NotificationService.initialize).
  registerNightlyBackupTask().catchError((_) {});
  runApp(const ProviderScope(child: ExpenseTrackerApp()));
}

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    ref.watch(notificationInitProvider);

    return MaterialApp.router(
      title: 'Expense Tracker',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      routerConfig: router,
    );
  }
}
