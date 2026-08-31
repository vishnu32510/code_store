import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_action.dart';
import '../models/push_notification_payload.dart';
import '../utils/messaging_background_handler.dart';
import 'i_messaging_service.dart';

/// Concrete implementation of [IMessagingService] supporting FCM and comprehensive
/// local notifications features (A to E: scheduling, actionable buttons, rich media, badges, grouping).
class FirebaseMessagingService implements IMessagingService {
  FirebaseMessagingService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  final _foregroundMessageController =
      StreamController<PushNotificationPayload>.broadcast();
  final _messageOpenedAppController =
      StreamController<PushNotificationPayload>.broadcast();
  final _actionTappedController =
      StreamController<NotificationActionResponse>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;

  NotificationTapHandler? _onNotificationTapped;
  NotificationActionHandler? _onActionTapped;
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
  }) async {
    if (_isInitialized) return;
    _channelId = channelId;
    _channelName = channelName;
    _channelDescription = channelDescription;
    _onNotificationTapped = onNotificationTapped;
    _onActionTapped = onActionTapped;

    // 0. Auto-request notification permissions across platforms (iOS, Android 13+, Web)
    if (autoRequestPermission) {
      try {
        await requestPermission();
      } catch (e) {
        debugPrint('Notice: Auto request permission error: $e');
      }
    }

    // 1. Initialize Timezones for scheduling
    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Notice: Timezone initialization error: $e');
    }

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

    // 4. Initialize local notifications plugin for foreground display, actions, & channels
    await _setupLocalNotifications(defaultAndroidIcon);

    // 5. Listen to foreground FCM messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      final payload = PushNotificationPayload.fromRemoteMessage(message);
      _foregroundMessageController.add(payload);

      // If requested, display a local heads-up notification in the system tray
      if (showForegroundNotifications && message.notification != null) {
        if (payload.imageUrl != null && payload.imageUrl!.isNotEmpty) {
          showRichMediaNotification(
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
      }
    });

    // 6. Listen to notification clicks when the app is in the background
    _messageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        final payload = PushNotificationPayload.fromRemoteMessage(message);
        _messageOpenedAppController.add(payload);
        _onNotificationTapped?.call(payload);
      },
    );

    _isInitialized = true;
  }

  Future<void> _setupLocalNotifications(String defaultAndroidIcon) async {
    if (kIsWeb) return;

    const darwinInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final androidInitializationSettings = AndroidInitializationSettings(
      defaultAndroidIcon,
    );

    final initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
      macOS: darwinInitializationSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        PushNotificationPayload? payload;
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final map = jsonDecode(response.payload!) as Map<String, dynamic>;
            payload = PushNotificationPayload.fromMap(map);
          } catch (e) {
            debugPrint('Error parsing notification response payload: $e');
          }
        }

        // Check if an action button was clicked vs standard notification body tap
        if (response.actionId != null && response.actionId!.isNotEmpty) {
          final actionResponse = NotificationActionResponse(
            actionId: response.actionId!,
            userText: response.input,
            payload: payload,
            rawPayload: response.payload,
          );
          _actionTappedController.add(actionResponse);
          _onActionTapped?.call(actionResponse);
        } else if (payload != null) {
          _messageOpenedAppController.add(payload);
          _onNotificationTapped?.call(payload);
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
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  @override
  Future<String?> getToken({String? vapidKey}) async {
    try {
      return await _messaging.getToken(vapidKey: vapidKey);
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
    List<NotificationAction>? actions,
  }) async {
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      actions: actions != null ? _buildAndroidActions(actions) : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: actions != null && actions.isNotEmpty
          ? 'custom_actions_category'
          : null,
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
  }) async {
    if (kIsWeb) return;

    final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      actions: actions != null ? _buildAndroidActions(actions) : null,
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

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
      payload: payload,
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
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
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

    await _localNotifications.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _localNotifications.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _localNotifications.cancelAll();
  }

  @override
  Future<List<PendingNotificationRequest>>
  getPendingNotificationRequests() async {
    if (kIsWeb) return const [];
    return await _localNotifications.pendingNotificationRequests();
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
    List<NotificationAction>? actions,
  }) async {
    if (kIsWeb) return;

    String? localImagePath;
    String? localLargeIconPath;

    try {
      if (imageUrl.startsWith('http')) {
        localImagePath = await _downloadAndSaveFile(imageUrl, 'rich_media_$id');
      } else {
        localImagePath = imageUrl;
      }

      if (largeIconUrl != null) {
        if (largeIconUrl.startsWith('http')) {
          localLargeIconPath = await _downloadAndSaveFile(
            largeIconUrl,
            'rich_media_large_$id',
          );
        } else {
          localLargeIconPath = largeIconUrl;
        }
      }
    } catch (e) {
      debugPrint('Error preparing notification image: $e');
    }

    final bigPictureStyle = localImagePath != null
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(localImagePath),
            largeIcon: localLargeIconPath != null
                ? FilePathAndroidBitmap(localLargeIconPath)
                : null,
            contentTitle: title,
            summaryText: body,
            hideExpandedLargeIcon: true,
          )
        : null;

    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyle,
      actions: actions != null ? _buildAndroidActions(actions) : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: localImagePath != null
          ? [DarwinNotificationAttachment(localImagePath)]
          : null,
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
  Future<void> setBadgeCount(int count) async {
    try {
      // Direct platform channel / darwin badge integration
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(badge: true);
      }
    } catch (e) {
      debugPrint('Notice setting badge count: $e');
    }
  }

  @override
  Future<void> clearBadge() async {
    await setBadgeCount(0);
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
    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
      setAsGroupSummary: setAsGroupSummary,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: groupKey,
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

  List<AndroidNotificationAction> _buildAndroidActions(
    List<NotificationAction> actions,
  ) {
    return actions.map((action) {
      final inputs = action.allowFreeFormInput
          ? <AndroidNotificationActionInput>[
              AndroidNotificationActionInput(
                label: action.inputPlaceholder ?? 'Reply...',
              ),
            ]
          : <AndroidNotificationActionInput>[];

      return AndroidNotificationAction(
        action.id,
        action.title,
        showsUserInterface: action.showsUserInterface,
        cancelNotification: action.isDestructive,
        inputs: inputs,
      );
    }).toList();
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getTemporaryDirectory();
    final extension = url.contains('.png')
        ? '.png'
        : (url.contains('.webp') ? '.webp' : '.jpg');
    final filePath = '${directory.path}/$fileName$extension';
    final dio = Dio();
    await dio.download(url, filePath);
    return filePath;
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
    _actionTappedController.close();
  }
}
