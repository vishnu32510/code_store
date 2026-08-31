import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/local_notification_action.dart';
import '../models/local_notification_payload.dart';

/// Callback invoked when a local notification banner is tapped by the user.
typedef LocalNotificationTapHandler = void Function(
  LocalNotificationPayload payload,
);

/// Callback invoked when an interactive action button is tapped.
typedef LocalNotificationActionHandler = void Function(
  LocalNotificationActionResponse response,
);

/// Abstract contract defining local notifications, scheduling, alarms, rich media, and badges.
abstract interface class ILocalNotificationService {
  /// Initializes the local notification plugin, creates channels, and sets up tap listeners.
  Future<void> initialize({
    String defaultAndroidIcon = '@mipmap/ic_launcher',
    String channelId = 'high_importance_channel',
    String channelName = 'High Importance Notifications',
    String channelDescription = 'This channel is used for important notifications.',
    LocalNotificationTapHandler? onNotificationTapped,
    LocalNotificationActionHandler? onActionTapped,
    void Function(String routePath)? onNavigate,
  });

  /// Requests notification permissions on iOS, macOS, and Android 13+.
  Future<bool?> requestPermission();

  /// Displays an immediate local notification banner in the system tray.
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
    List<LocalNotificationAction>? actions,
  });

  /// Schedules a local notification to fire at a specific future date and time.
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
    List<LocalNotificationAction>? actions,
  });

  /// Periodically schedules a recurring notification (e.g. daily, hourly, every minute).
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

  /// Cancels a specific notification by ID.
  Future<void> cancelNotification(int id);

  /// Cancels all active and pending scheduled notifications.
  Future<void> cancelAllNotifications();

  /// Retrieves a list of all currently pending scheduled notification requests.
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests();

  /// Displays a Rich Media Notification with an expandable Big Picture banner.
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
    List<LocalNotificationAction>? actions,
  });

  /// Sets or updates the app icon badge count (iOS / supported Android launchers).
  Future<void> setBadgeCount(int count);

  /// Clears the app icon badge count.
  Future<void> clearBadge();

  /// Displays a grouped / threaded notification with support for group keys and summaries.
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

  /// Stream emitting events when a user taps an action button or enters quick reply text.
  Stream<LocalNotificationActionResponse> get onActionTapped;

  /// Stream emitting events when a user taps a local notification body.
  Stream<LocalNotificationPayload> get onNotificationTapped;

  /// Closes active streams and resources.
  void dispose();
}
