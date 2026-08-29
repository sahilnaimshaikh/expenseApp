import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core_data/domain/budget_status.dart';
import '../../core_data/domain/models/enums.dart';

/// Thin dispatch wrapper around flutter_local_notifications. No business
/// logic — per services.md, this class never decides *whether* to notify,
/// only *how* to present a notification it's told to fire.
///
/// Failures are caught and swallowed (logged only) per the fail-safe
/// notification dispatch pattern in nfr-design-patterns.md — a failed
/// notification must never propagate and disrupt the budget/expense flow
/// that triggered it.
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'budget_alerts';
  static const String _channelName = 'Budget Alerts';

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    try {
      await _plugin.initialize(initSettings);
    } catch (_) {
      // Fail-safe: notification setup failure must not crash app startup.
    }
  }

  Future<void> notifyThresholdCrossed(ThresholdCrossing crossing) async {
    final scopeLabel = switch (crossing.ledgerScope) {
      LedgerScope.personal => 'personal',
      LedgerScope.home => 'home',
      LedgerScope.combined => 'combined',
    };

    final title = crossing.threshold >= 100 ? 'Budget exceeded' : 'Budget alert';
    final body = "You've used ${crossing.threshold}% of your $scopeLabel budget this month.";

    await _show(
      id: crossing.threshold + crossing.month * 1000,
      title: title,
      body: body,
    );
  }

  Future<void> notifyEndOfMonthSummary(String summaryText) async {
    await _show(id: 999999, title: 'Monthly Summary', body: summaryText);
  }

  Future<void> _show({required int id, required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    try {
      await _plugin.show(id, title, body, details);
    } catch (_) {
      // Fail-safe dispatch: swallow platform errors (e.g. permission
      // denied) rather than letting them bubble into the caller's flow.
    }
  }
}
