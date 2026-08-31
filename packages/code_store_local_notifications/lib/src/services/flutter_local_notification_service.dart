import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/local_notification_action.dart';
import '../models/local_notification_payload.dart';
import 'i_local_notification_service.dart';

/// Concrete implementation of [ILocalNotificationService] backed by `flutter_local_notifications`.
class FlutterLocalNotificationService implements ILocalNotificationService {
  FlutterLocalNotificationService({
    FlutterLocalNotificationsPlugin? localNotifications,
    Dio? dio,
  })  : _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _dio = dio ?? Dio();

  final FlutterLocalNotificationsPlugin _localNotifications;
  final Dio _dio;

  final _actionTappedController =
      StreamController<LocalNotificationActionResponse>.broadcast();
  final _notificationTappedController =
      StreamController<LocalNotificationPayload>.broadcast();

  LocalNotificationTapHandler? _onNotificationTapped;
  LocalNotificationActionHandler? _onActionTapped;
  void Function(String routePath)? _onNavigate;

  bool _isInitialized = false;
  String _channelId = 'high_importance_channel';
  String _channelName = 'High Importance Notifications';
  String _channelDescription =
      'This channel is used for important notifications.';

  @override
  Stream<LocalNotificationActionResponse> get onActionTapped =>
      _actionTappedController.stream;

  @override
  Stream<LocalNotificationPayload> get onNotificationTapped =>
      _notificationTappedController.stream;

  @override
  Future<void> initialize({
    String defaultAndroidIcon = '@mipmap/ic_launcher',
    String channelId = 'high_importance_channel',
    String channelName = 'High Importance Notifications',
    String channelDescription =
        'This channel is used for important notifications.',
    LocalNotificationTapHandler? onNotificationTapped,
    LocalNotificationActionHandler? onActionTapped,
    void Function(String routePath)? onNavigate,
  }) async {
    if (_isInitialized) return;
    _channelId = channelId;
    _channelName = channelName;
    _channelDescription = channelDescription;
    _onNotificationTapped = onNotificationTapped;
    _onActionTapped = onActionTapped;
    _onNavigate = onNavigate;

    // 1. Initialize Timezones
    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Notice: Timezone initialization error: $e');
    }

    // 2. Initialize local notifications plugin
    if (!kIsWeb) {
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      final androidInit = AndroidInitializationSettings(defaultAndroidIcon);

      final initializationSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      final androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);

      // Check cold-start launch from a notification
      final launchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (launchDetails != null &&
          launchDetails.didNotificationLaunchApp &&
          launchDetails.notificationResponse != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationResponse(launchDetails.notificationResponse!);
        });
      }
    }

    _isInitialized = true;
  }

  void _handleNotificationResponse(NotificationResponse response) {
    LocalNotificationPayload? payload;
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final map = jsonDecode(response.payload!) as Map<String, dynamic>;
        payload = LocalNotificationPayload.fromMap(map);
      } catch (e) {
        debugPrint('Error parsing local notification payload: $e');
      }
    }

    if (response.actionId != null && response.actionId!.isNotEmpty) {
      final actionResponse = LocalNotificationActionResponse(
        actionId: response.actionId!,
        userText: response.input,
        payload: payload,
        rawPayload: response.payload,
      );
      _actionTappedController.add(actionResponse);
      _onActionTapped?.call(actionResponse);
    } else if (payload != null) {
      _notificationTappedController.add(payload);
      _onNotificationTapped?.call(payload);
      if (_onNavigate != null) {
        final route = payload.routePath ?? '/notifications';
        _onNavigate?.call(route);
      }
    }
  }

  @override
  Future<bool?> requestPermission() async {
    if (kIsWeb) return null;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
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
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      actions: actions
          ?.map(
            (a) => AndroidNotificationAction(
              a.id,
              a.title,
              icon: a.icon != null
                  ? DrawableResourceAndroidBitmap(a.icon!)
                  : null,
              showsUserInterface: a.showsUserInterface,
              allowGeneratedReplies: a.allowFreeFormInput,
              inputs: a.allowFreeFormInput
                  ? [
                      AndroidNotificationActionInput(
                        label: a.inputPlaceholder ?? 'Reply...',
                      ),
                    ]
                  : const [],
            ),
          )
          .toList(),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: actions != null && actions.isNotEmpty
          ? 'actionable_category'
          : null,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
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
    List<LocalNotificationAction>? actions,
  }) async {
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      actions: actions
          ?.map(
            (a) => AndroidNotificationAction(
              a.id,
              a.title,
              icon: a.icon != null
                  ? DrawableResourceAndroidBitmap(a.icon!)
                  : null,
            ),
          )
          .toList(),
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
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
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
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
    if (kIsWeb) return [];
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
    List<LocalNotificationAction>? actions,
  }) async {
    if (kIsWeb) return;

    String? bigPicturePath;
    String? largeIconPath;
    String? iosAttachmentPath;

    try {
      bigPicturePath = await _downloadAndSaveFile(imageUrl, 'big_pic_$id.jpg');
      iosAttachmentPath = bigPicturePath;
      if (largeIconUrl != null) {
        largeIconPath = await _downloadAndSaveFile(
          largeIconUrl,
          'large_icon_$id.jpg',
        );
      }
    } catch (e) {
      debugPrint('Error downloading rich media image: $e');
    }

    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPicturePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(bigPicturePath),
              largeIcon: largeIconPath != null
                  ? FilePathAndroidBitmap(largeIconPath)
                  : null,
              contentTitle: title,
              summaryText: body,
            )
          : null,
      actions: actions
          ?.map(
            (a) => AndroidNotificationAction(
              a.id,
              a.title,
              icon: a.icon != null
                  ? DrawableResourceAndroidBitmap(a.icon!)
                  : null,
            ),
          )
          .toList(),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: iosAttachmentPath != null
          ? [DarwinNotificationAttachment(iosAttachmentPath)]
          : null,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  @override
  Future<void> setBadgeCount(int count) async {
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.show(
            0,
            '',
            '',
            notificationDetails: DarwinNotificationDetails(badgeNumber: count),
          );
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
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      channelName ?? _channelName,
      channelDescription: channelDescription ?? _channelDescription,
      importance: Importance.high,
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

    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null) {
        final file = File(filePath);
        await file.writeAsBytes(response.data!);
        return filePath;
      }
    } catch (e) {
      debugPrint('Failed to download image file: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _actionTappedController.close();
    _notificationTappedController.close();
  }
}
