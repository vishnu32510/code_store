library;

// Re-export local notifications for unified developer experience
export 'package:code_store_local_notifications/code_store_local_notifications.dart';

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

// Widgets & Prompts
export 'src/widgets/notification_permission_dialog.dart';
