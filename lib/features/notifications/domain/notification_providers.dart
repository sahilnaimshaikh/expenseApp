import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

final Provider<NotificationService> notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});

/// Triggers [NotificationService.initialize] once at app startup. Watched
/// (not read) from the app root widget so it runs exactly once per app
/// lifetime, before any screen tries to fire a notification.
final FutureProvider<void> notificationInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(notificationServiceProvider);
  await service.initialize();
});
