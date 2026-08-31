import 'dart:async';
import 'dart:convert';

import 'package:code_store_local_notifications/code_store_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/notification_action.dart';
import '../models/push_notification_payload.dart';
import '../utils/messaging_background_handler.dart';
import '../utils/web_notification_helper.dart';
import 'i_messaging_service.dart';

/// Concrete implementation of [IMessagingService] supporting FCM and delegating
/// local notification features (A to E: scheduling, actionable buttons, rich media, badges, grouping)
/// to the modular [ILocalNotificationService].
class FirebaseMessagingService implements IMessagingService {
  FirebaseMessagingService({
    FirebaseMessaging? messaging,
    ILocalNotificationService? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationService();

  final FirebaseMessaging _messaging;
  final ILocalNotificationService _localNotifications;

  final _foregroundMessageController =
      StreamController<PushNotificationPayload>.broadcast();
  final _messageOpenedAppController =
      StreamController<PushNotificationPayload>.broadcast();
  final _actionTappedController =
      StreamController<NotificationActionResponse>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;
  StreamSubscription<LocalNotificationActionResponse>? _actionSubscription;

  NotificationTapHandler? _onNotificationTapped;
  NotificationActionHandler? _onActionTapped;
  void Function(String routePath)? _onNavigate;
  bool _isInitialized = false;
  String _channelId = 'high_importance_channel';
  String _channelName = 'High Importance Notifications';
  String _channelDescription =
      'This channel is used for important notifications.';

  @override
  Stream<PushNotificationPayload> get onForegroundMessage =>
      _foregroundMessageController.stream;

  @override
  Stream<PushNotificationPayload> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;

  @override
  Stream<NotificationActionResponse> get onActionTapped =>
      _actionTappedController.stream;

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<void> initialize({
    bool autoRequestPermission = true,
    bool showForegroundNotifications = true,
    String defaultAndroidIcon = '@mipmap/ic_launcher',
    String channelId = 'high_importance_channel',
    String channelName = 'High Importance Notifications',
    String channelDescription =
        'This channel is used for important notifications.',
    NotificationTapHandler? onNotificationTapped,
    NotificationActionHandler? onActionTapped,
    void Function(String routePath)? onNavigate,
  }) async {
    if (_isInitialized) return;
    _channelId = channelId;
    _channelName = channelName;
    _channelDescription = channelDescription;
    _onNotificationTapped = onNotificationTapped;
    _onActionTapped = onActionTapped;
    _onNavigate = onNavigate;

    // 0. Auto-request notification permissions across platforms
    if (autoRequestPermission) {
      try {
        await requestPermission();
      } catch (e) {
        debugPrint('Notice: Auto request permission error: $e');
      }
    }

    // 1. Initialize local notification delegate service
    await _localNotifications.initialize(
      defaultAndroidIcon: defaultAndroidIcon,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      onNotificationTapped: (localPayload) {
        final payload = PushNotificationPayload(
          id: localPayload.id,
          title: localPayload.title,
          body: localPayload.body,
          imageUrl: localPayload.imageUrl,
          data: localPayload.data,
          sentTime: localPayload.sentTime,
          category: localPayload.category,
        );
        _dispatchNotificationTap(payload);
      },
      onActionTapped: (actionResponse) {
        final resp = NotificationActionResponse(
          actionId: actionResponse.actionId,
          userText: actionResponse.userText,
          payload: actionResponse.payload,
          rawPayload: actionResponse.rawPayload,
        );
        _actionTappedController.add(resp);
        _onActionTapped?.call(resp);
      },
      onNavigate: onNavigate,
    );

    _actionSubscription = _localNotifications.onActionTapped.listen((action) {
      final resp = NotificationActionResponse(
        actionId: action.actionId,
        userText: action.userText,
        payload: action.payload,
        rawPayload: action.rawPayload,
      );
      _actionTappedController.add(resp);
    });

    // 2. Register top-level background handler
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Notice: onBackgroundMessage setup: $e');
    }

    // 3. Configure foreground presentation options for Apple platforms
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Notice: setForegroundNotificationPresentationOptions: $e');
    }

    // 4. Listen to foreground FCM messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      final payload = PushNotificationPayload.fromRemoteMessage(message);
      _foregroundMessageController.add(payload);

      // If requested, display a local heads-up notification in the system tray
      if (showForegroundNotifications && message.notification != null) {
        if (payload.imageUrl != null && payload.imageUrl!.isNotEmpty) {
          _localNotifications.showRichMediaNotification(
            id: message.hashCode,
            title: payload.title ?? '',
            body: payload.body ?? '',
            imageUrl: payload.imageUrl!,
            payload: jsonEncode(payload.toMap()),
            channelId: _channelId,
            channelName: _channelName,
            channelDescription: _channelDescription,
          );
        } else {
          _localNotifications.showLocalNotification(
            id: message.hashCode,
            title: payload.title ?? '',
            body: payload.body ?? '',
            payload: jsonEncode(payload.toMap()),
            channelId: _channelId,
            channelName: _channelName,
            channelDescription: _channelDescription,
          );
        }
      }
    });

    // 5. Listen to notification clicks when the app is in the background
    _messageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        final payload = PushNotificationPayload.fromRemoteMessage(message);
        _messageOpenedAppController.add(payload);
        _dispatchNotificationTap(payload);
      },
    );

    // 6. Check if app was launched from a terminated state by tapping a notification
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        final payload = PushNotificationPayload.fromRemoteMessage(
          initialMessage,
        );
        _messageOpenedAppController.add(payload);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _dispatchNotificationTap(payload);
        });
      }
    } catch (e) {
      debugPrint('Notice: getInitialMessage error: $e');
    }

    _isInitialized = true;
  }

  void _dispatchNotificationTap(PushNotificationPayload payload) {
    _onNotificationTapped?.call(payload);
    if (_onNavigate != null) {
      final route = payload.routePath ?? '/notifications';
      _onNavigate?.call(route);
    }
  }

  @override
  Future<String?> getToken({String? vapidKey}) async {
    try {
      if (kIsWeb) {
        final activeKey = vapidKey ?? getWebPushVapidKey();
        return await _messaging.getToken(vapidKey: activeKey);
      }
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error retrieving FCM token: $e');
      return null;
    }
  }

  @override
  Future<String?> getAPNSToken() async {
    if (kIsWeb) return null;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        return await _messaging.getAPNSToken();
      }
    } catch (e) {
      debugPrint('Error retrieving APNs token: $e');
    }
    return null;
  }

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    return await _messaging.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
    );
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) {
      debugPrint('Notice: Topic subscription is not supported on Web.');
      return;
    }
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('Error subscribing to topic "$topic": $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) return;
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('Error unsubscribing from topic "$topic": $e');
    }
  }

  @override
  Future<PushNotificationPayload?> getInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();
      if (message != null) {
        return PushNotificationPayload.fromRemoteMessage(message);
      }
    } catch (e) {
      debugPrint('Error retrieving initial message: $e');
    }
    return null;
  }

  @override
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
    List<LocalNotificationAction>? actions,
  }) async {
    await _localNotifications.showLocalNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      actions: actions,
    );
  }

  @override
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
  }) async {
    await _localNotifications.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      matchDateTimeComponents: matchDateTimeComponents,
      actions: actions,
    );
  }

  @override
  Future<void> periodicallyShowNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
  }) async {
    await _localNotifications.periodicallyShowNotification(
      id: id,
      title: title,
      body: body,
      repeatInterval: repeatInterval,
      payload: payload,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancelNotification(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAllNotifications();
  }

  @override
  Future<List<PendingNotificationRequest>>
  getPendingNotificationRequests() async {
    return await _localNotifications.getPendingNotificationRequests();
  }

  @override
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
  }) async {
    await _localNotifications.showRichMediaNotification(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      largeIconUrl: largeIconUrl,
      payload: payload,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      actions: actions,
    );
  }

  @override
  Future<void> setBadgeCount(int count) async {
    await _localNotifications.setBadgeCount(count);
  }

  @override
  Future<void> clearBadge() async {
    await _localNotifications.clearBadge();
  }

  @override
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
  }) async {
    await _localNotifications.showGroupedNotification(
      id: id,
      title: title,
      body: body,
      groupKey: groupKey,
      setAsGroupSummary: setAsGroupSummary,
      payload: payload,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  @override
  void dispose() {
    _foregroundSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
    _actionSubscription?.cancel();
    _foregroundMessageController.close();
    _messageOpenedAppController.close();
    _actionTappedController.close();
    _localNotifications.dispose();
  }
}
