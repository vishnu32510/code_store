import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler required by FCM.
///
/// This function MUST be a top-level or static function with the
/// `@pragma('vm:entry-point')` annotation so the Dart VM can invoke it
/// even if the app is terminated or running in a background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Ensure Firebase is initialized in the background isolate if needed
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Background Firebase init notice: $e');
  }

  debugPrint(
    '[FCM Background Message] ID: ${message.messageId}, Data: ${message.data}, Notification: ${message.notification?.title}',
  );
}
