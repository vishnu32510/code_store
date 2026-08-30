import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import '../services/firebase_messaging_service.dart';
import '../services/i_messaging_service.dart';

/// Registers Push Notification and Firebase Messaging services into [GetIt].
///
/// If [locator] is omitted, [GetIt.instance] is used.
/// You can pass a custom [messagingInstance], [localNotificationsInstance],
/// or [customService] for mock / unit testing environments.
void setupMessagingDI({
  GetIt? locator,
  FirebaseMessaging? messagingInstance,
  FlutterLocalNotificationsPlugin? localNotificationsInstance,
  IMessagingService? customService,
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<IMessagingService>()) {
      di.registerSingleton<IMessagingService>(customService);
    }
    return;
  }

  if (!di.isRegistered<IMessagingService>()) {
    final service = FirebaseMessagingService(
      messaging: messagingInstance,
      localNotifications: localNotificationsInstance,
    );
    di.registerSingleton<IMessagingService>(service);

    if (!di.isRegistered<FirebaseMessagingService>()) {
      di.registerSingleton<FirebaseMessagingService>(service);
    }
  }
}
