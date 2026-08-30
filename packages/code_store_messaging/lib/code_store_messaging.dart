library;

// Re-export firebase_messaging types commonly needed by consuming apps
export 'package:firebase_messaging/firebase_messaging.dart'
    show
        FirebaseMessaging,
        RemoteMessage,
        RemoteNotification,
        NotificationSettings,
        AuthorizationStatus,
        AppleNotificationSetting,
        AppleShowPreviewSetting;

// Re-export flutter_local_notifications types for channels, scheduling, and intervals
export 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        FlutterLocalNotificationsPlugin,
        AndroidNotificationChannel,
        AndroidNotificationDetails,
        DarwinNotificationDetails,
        NotificationDetails,
        Importance,
        Priority,
        NotificationResponse,
        PendingNotificationRequest,
        RepeatInterval,
        DateTimeComponents;

// DI
export 'src/di/messaging_injection.dart';

// Models
export 'src/models/notification_action.dart';
export 'src/models/push_notification_payload.dart';

// Services
export 'src/services/firebase_messaging_service.dart';
export 'src/services/i_messaging_service.dart';

// Background & Utils
export 'src/utils/messaging_background_handler.dart';
