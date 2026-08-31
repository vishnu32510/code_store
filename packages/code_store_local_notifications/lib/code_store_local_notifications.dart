library;

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
export 'src/di/local_notifications_injection.dart';

// Models
export 'src/models/local_notification_action.dart';
export 'src/models/local_notification_payload.dart';

// Services
export 'src/services/flutter_local_notification_service.dart';
export 'src/services/i_local_notification_service.dart';
