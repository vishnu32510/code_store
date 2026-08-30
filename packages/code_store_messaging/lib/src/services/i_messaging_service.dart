import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/push_notification_payload.dart';

/// Callback invoked when a notification is tapped by the user.
typedef NotificationTapHandler = void Function(PushNotificationPayload payload);

/// Contract defining push notification operations and lifecycle listeners.
abstract interface class IMessagingService {
  /// Initializes push notification listeners, registers background handlers,
  /// and configures the local notification display plugin for foreground presentation.
  Future<void> initialize({
    bool showForegroundNotifications = true,
    String defaultAndroidIcon = '@mipmap/ic_launcher',
    String channelId = 'high_importance_channel',
    String channelName = 'High Importance Notifications',
    String channelDescription = 'This channel is used for important notifications.',
    NotificationTapHandler? onNotificationTapped,
  });

  /// Retrieves the current Firebase Cloud Messaging registration token for this device.
  Future<String?> getToken();

  /// Retrieves the Apple Push Notification Service (APNs) device token (iOS/macOS only).
  Future<String?> getAPNSToken();

  /// Stream that emits whenever the FCM registration token is generated or refreshed.
  Stream<String> get onTokenRefresh;

  /// Requests user permission to receive notifications on iOS, macOS, and Android 13+ (POST_NOTIFICATIONS).
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  });

  /// Retrieves the current notification permission settings.
  Future<NotificationSettings> getNotificationSettings();

  /// Subscribes the current device to an FCM topic.
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes the current device from an FCM topic.
  Future<void> unsubscribeFromTopic(String topic);

  /// Stream emitting incoming messages received while the app is in the foreground.
  Stream<PushNotificationPayload> get onForegroundMessage;

  /// Stream emitting notification payloads when the app is opened from a background notification tap.
  Stream<PushNotificationPayload> get onMessageOpenedApp;

  /// Retrieves the payload of the notification that launched/cold-started the app from a terminated state.
  Future<PushNotificationPayload?> getInitialMessage();

  /// Manually displays a local notification banner.
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
  });

  /// Deletes the current FCM token, causing FCM to generate a new token on next request.
  Future<void> deleteToken();

  /// Closes any open streams and controllers.
  void dispose();
}
