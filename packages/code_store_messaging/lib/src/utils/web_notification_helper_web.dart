import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Native Web HTML5 Notification invocation.
void showWebBrowserNotification(
  String title,
  String body, {
  String? icon,
  String? tag,
}) {
  try {
    if (web.Notification.permission == 'granted') {
      final options = web.NotificationOptions(
        body: body,
        icon: icon ?? '/favicon.png',
        tag: tag ?? 'code_store_notification',
      );
      web.Notification(title, options);
    } else {
      debugPrint(
        'Web Notification permission not granted (status: ${web.Notification.permission})',
      );
    }
  } catch (e) {
    debugPrint('Failed to display native Web Notification: $e');
  }
}

String? getWebPushVapidKey() => null;
