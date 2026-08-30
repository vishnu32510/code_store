import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/push_notification_payload.dart';
import '../utils/messaging_background_handler.dart';
import 'i_messaging_service.dart';

/// Concrete implementation of [IMessagingService] utilizing Firebase Cloud Messaging
/// and FlutterLocalNotificationsPlugin for complete push notification lifecycle management.
class FirebaseMessagingService implements IMessagingService {
  FirebaseMessagingService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  final _foregroundMessageController =
      StreamController<PushNotificationPayload>.broadcast();
  final _messageOpenedAppController =
      StreamController<PushNotificationPayload>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;

  NotificationTapHandler? _onNotificationTapped;
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
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<void> initialize({
    bool showForegroundNotifications = true,
    String defaultAndroidIcon = '@mipmap/ic_launcher',
    String channelId = 'high_importance_channel',
    String channelName = 'High Importance Notifications',
    String channelDescription =
        'This channel is used for important notifications.',
    NotificationTapHandler? onNotificationTapped,
  }) async {
    if (_isInitialized) return;
    _channelId = channelId;
    _channelName = channelName;
    _channelDescription = channelDescription;
    _onNotificationTapped = onNotificationTapped;

    // Register top-level background handler
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Notice: onBackgroundMessage setup: $e');
    }

    // Configure foreground presentation options for Apple platforms
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Notice: setForegroundNotificationPresentationOptions: $e');
    }

    // Initialize local notifications plugin for foreground display and Android channels
    await _setupLocalNotifications(defaultAndroidIcon);

    // Listen to foreground FCM messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      final payload = PushNotificationPayload.fromRemoteMessage(message);
      _foregroundMessageController.add(payload);

      // If requested, display a local heads-up notification in the system tray
      if (showForegroundNotifications && message.notification != null) {
        showLocalNotification(
          id: message.hashCode,
          title: payload.title ?? '',
          body: payload.body ?? '',
          payload: jsonEncode(payload.toMap()),
          channelId: _channelId,
          channelName: _channelName,
          channelDescription: _channelDescription,
        );
      }
    });

    // Listen to notification clicks when the app is in the background
    _messageOpenedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final payload = PushNotificationPayload.fromRemoteMessage(message);
      _messageOpenedAppController.add(payload);
      _onNotificationTapped?.call(payload);
    });

    _isInitialized = true;
  }

  Future<void> _setupLocalNotifications(String defaultAndroidIcon) async {
    const darwinInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final androidInitializationSettings =
        AndroidInitializationSettings(defaultAndroidIcon);

    final initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
      macOS: darwinInitializationSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final map = jsonDecode(response.payload!) as Map<String, dynamic>;
            final payload = PushNotificationPayload.fromMap(map);
            _messageOpenedAppController.add(payload);
            _onNotificationTapped?.call(payload);
          } catch (e) {
            debugPrint('Error parsing notification response payload: $e');
          }
        }
      },
    );

    // Create default high-importance notification channel on Android
    final androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error retrieving FCM token: $e');
      return null;
    }
  }

  @override
  Future<String?> getAPNSToken() async {
    try {
      return await _messaging.getAPNSToken();
    } catch (e) {
      debugPrint('Error retrieving APNs token: $e');
      return null;
    }
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
    await _messaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  @override
  Future<PushNotificationPayload?> getInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();
      if (message != null) {
        return PushNotificationPayload.fromRemoteMessage(message);
      }
    } catch (e) {
      debugPrint('Error retrieving initial FCM message: $e');
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
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  @override
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }

  @override
  void dispose() {
    _foregroundSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
    _foregroundMessageController.close();
    _messageOpenedAppController.close();
  }
}
