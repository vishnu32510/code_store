import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_action.dart';
import '../models/push_notification_payload.dart';

/// Callback invoked when a notification is tapped by the user.
typedef NotificationTapHandler = void Function(PushNotificationPayload payload);

/// Callback invoked when an action button or text reply is submitted on a notification.
typedef NotificationActionHandler = void Function(
    NotificationActionResponse response);

/// Contract defining push notification operations, lifecycle listeners,
/// scheduling, actionable quick buttons, rich media, and badge management.
abstract interface class IMessagingService {
  /// Initializes push notification listeners, registers background handlers,
  /// initializes timezones, and configures the local notification plugin.
  Future<void> initialize({
    bool showForegroundNotifications = true,
    String defaultAndroidIcon = '@mipmap/ic_launcher',
    String channelId = 'high_importance_channel',
    String channelName = 'High Importance Notifications',
    String channelDescription =
        'This channel is used for important notifications.',
    NotificationTapHandler? onNotificationTapped,
    NotificationActionHandler? onActionTapped,
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

  /// Stream emitting events when a user interacts with quick action buttons or submits text replies.
  Stream<NotificationActionResponse> get onActionTapped;

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
    List<NotificationAction>? actions,
  });

  /// (A) Schedules a notification to trigger at a specific future date and time.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
    DateTimeComponents? matchDateTimeComponents,
    List<NotificationAction>? actions,
  });

  /// (A) Periodically schedules a recurring notification (e.g. daily, hourly, every minute).
  Future<void> periodicallyShowNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
  });

  /// (A) Cancels a specific scheduled or active notification by ID.
  Future<void> cancelNotification(int id);

  /// (A) Cancels all active and scheduled notifications.
  Future<void> cancelAllNotifications();

  /// (A) Retrieves a list of all currently pending scheduled notification requests.
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests();

  /// (C) Displays a Rich Media Notification with an expandable Big Picture (remote URL or local file).
  Future<void> showRichMediaNotification({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
    String? largeIconUrl,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
    List<NotificationAction>? actions,
  });

  /// (D) Sets or updates the app icon badge count (iOS / supported Android launchers).
  Future<void> setBadgeCount(int count);

  /// (D) Clears the app icon badge count.
  Future<void> clearBadge();

  /// (E) Displays a grouped / threaded notification with support for group keys and summaries.
  Future<void> showGroupedNotification({
    required int id,
    required String title,
    required String body,
    required String groupKey,
    bool setAsGroupSummary = false,
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
