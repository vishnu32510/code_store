import 'package:code_store_local_notifications/code_store_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import '../services/firebase_messaging_service.dart';
import '../services/i_messaging_service.dart';

/// Registers Push Notification and Firebase Messaging services into [GetIt].
///
/// Automatically sets up [ILocalNotificationService] if not already registered.
void setupMessagingDI({
  GetIt? locator,
  FirebaseMessaging? messagingInstance,
  ILocalNotificationService? localNotificationsInstance,
  IMessagingService? customService,
}) {
  final di = locator ?? GetIt.instance;

  // 1. Ensure local notifications are registered
  setupLocalNotificationsDI(sl: di);

  if (customService != null) {
    if (!di.isRegistered<IMessagingService>()) {
      di.registerSingleton<IMessagingService>(customService);
    }
    return;
  }

  if (!di.isRegistered<IMessagingService>()) {
    final localNotifications =
        localNotificationsInstance ?? di<ILocalNotificationService>();
    final service = FirebaseMessagingService(
      messaging: messagingInstance,
      localNotifications: localNotifications,
    );
    di.registerSingleton<IMessagingService>(service);

    if (!di.isRegistered<FirebaseMessagingService>()) {
      di.registerSingleton<FirebaseMessagingService>(service);
    }
  }
}
