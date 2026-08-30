import 'dart:async';

import 'package:code_store_messaging/code_store_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockMessagingService implements IMessagingService {
  final _foregroundController =
      StreamController<PushNotificationPayload>.broadcast();
  final _openedAppController =
      StreamController<PushNotificationPayload>.broadcast();
  final _actionTappedController =
      StreamController<NotificationActionResponse>.broadcast();
  final _tokenRefreshController = StreamController<String>.broadcast();

  bool initialized = false;
  String? currentToken = 'mock_fcm_token_123';
  int badgeCount = 0;
  final List<String> subscribedTopics = [];
  final List<Map<String, dynamic>> shownLocalNotifications = [];
  final List<Map<String, dynamic>> scheduledNotifications = [];
  final List<Map<String, dynamic>> richMediaNotifications = [];
  final List<Map<String, dynamic>> groupedNotifications = [];

  @override
  Stream<PushNotificationPayload> get onForegroundMessage =>
      _foregroundController.stream;

  @override
  Stream<PushNotificationPayload> get onMessageOpenedApp =>
      _openedAppController.stream;

  @override
  Stream<NotificationActionResponse> get onActionTapped =>
      _actionTappedController.stream;

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Future<void> initialize({
    bool showForegroundNotifications = true,
    String defaultAndroidIcon = '@mipmap/ic_launcher',
    String channelId = 'high_importance_channel',
    String channelName = 'High Importance Notifications',
    String channelDescription =
        'This channel is used for important notifications.',
    NotificationTapHandler? onNotificationTapped,
    NotificationActionHandler? onActionTapped,
  }) async {
    initialized = true;
  }

  @override
  Future<String?> getToken() async => currentToken;

  @override
  Future<String?> getAPNSToken() async => 'mock_apns_token_456';

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
    return NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.notSupported,
      authorizationStatus: AuthorizationStatus.authorized,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      sound: AppleNotificationSetting.enabled,
      timeSensitive: AppleNotificationSetting.notSupported,
      providesAppNotificationSettings: AppleNotificationSetting.notSupported,
    );
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    return NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.notSupported,
      authorizationStatus: AuthorizationStatus.authorized,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      sound: AppleNotificationSetting.enabled,
      timeSensitive: AppleNotificationSetting.notSupported,
      providesAppNotificationSettings: AppleNotificationSetting.notSupported,
    );
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    subscribedTopics.add(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    subscribedTopics.remove(topic);
  }

  @override
  Future<PushNotificationPayload?> getInitialMessage() async {
    return const PushNotificationPayload(
      id: 'cold_start_1',
      title: 'Welcome Back',
      body: 'Launch from terminated state',
    );
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
    shownLocalNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'actions': actions,
    });
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
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'actions': actions,
    });
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
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'repeatInterval': repeatInterval,
    });
  }

  @override
  Future<void> cancelNotification(int id) async {
    scheduledNotifications.removeWhere((item) => item['id'] == id);
    shownLocalNotifications.removeWhere((item) => item['id'] == id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    scheduledNotifications.clear();
    shownLocalNotifications.clear();
  }

  @override
  Future<List<PendingNotificationRequest>>
  getPendingNotificationRequests() async {
    return [
      const PendingNotificationRequest(
        1,
        'Reminder',
        'Check tasks',
        'payload_1',
      ),
    ];
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
    richMediaNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'largeIconUrl': largeIconUrl,
      'actions': actions,
    });
  }

  @override
  Future<void> setBadgeCount(int count) async {
    badgeCount = count;
  }

  @override
  Future<void> clearBadge() async {
    badgeCount = 0;
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
    groupedNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'groupKey': groupKey,
      'setAsGroupSummary': setAsGroupSummary,
    });
  }

  @override
  Future<void> deleteToken() async {
    currentToken = null;
  }

  @override
  void dispose() {
    _foregroundController.close();
    _openedAppController.close();
    _actionTappedController.close();
    _tokenRefreshController.close();
  }
}

void main() {
  group('PushNotificationPayload & NotificationAction Tests', () {
    test('Constructs and converts to Map correctly', () {
      final now = DateTime.now();
      final payload = PushNotificationPayload(
        id: 'msg_101',
        title: 'Flash Sale!',
        body: '50% off everything',
        imageUrl: 'https://example.com/banner.png',
        data: {'route': '/sale', 'promo_id': '50OFF'},
        sentTime: now,
        category: 'promotions',
        from: '/topics/promotions',
      );

      expect(payload.id, 'msg_101');
      expect(payload.title, 'Flash Sale!');
      expect(payload.body, '50% off everything');
      expect(payload.imageUrl, 'https://example.com/banner.png');
      expect(payload.data['route'], '/sale');

      final map = payload.toMap();
      expect(map['id'], 'msg_101');
      expect(map['title'], 'Flash Sale!');
      expect(map['imageUrl'], 'https://example.com/banner.png');
      expect(map['data']['promo_id'], '50OFF');

      final deserialized = PushNotificationPayload.fromMap(map);
      expect(deserialized.id, payload.id);
      expect(deserialized.title, payload.title);
      expect(deserialized.body, payload.body);
      expect(deserialized.imageUrl, payload.imageUrl);
    });

    test('NotificationAction models construct correctly', () {
      const action = NotificationAction(
        id: 'accept_order',
        title: 'Accept',
        showsUserInterface: true,
        allowFreeFormInput: true,
        inputPlaceholder: 'Type a message...',
      );

      expect(action.id, 'accept_order');
      expect(action.title, 'Accept');
      expect(action.allowFreeFormInput, isTrue);

      const response = NotificationActionResponse(
        actionId: 'accept_order',
        userText: 'On my way!',
      );
      expect(response.actionId, 'accept_order');
      expect(response.userText, 'On my way!');
    });
  });

  group('Messaging DI & Advanced Features Tests (A to E)', () {
    late GetIt testLocator;

    setUp(() {
      testLocator = GetIt.asNewInstance();
    });

    test(
      'Executes all advanced notification methods on IMessagingService',
      () async {
        final mockService = MockMessagingService();
        setupMessagingDI(locator: testLocator, customService: mockService);

        expect(testLocator.isRegistered<IMessagingService>(), isTrue);
        final resolved = testLocator<IMessagingService>();

        await resolved.initialize();
        expect(mockService.initialized, isTrue);

        // A: Scheduling
        final futureDate = DateTime.now().add(const Duration(hours: 1));
        await resolved.scheduleNotification(
          id: 10,
          title: 'Drink Water',
          body: 'Stay hydrated',
          scheduledDate: futureDate,
        );
        expect(mockService.scheduledNotifications.length, 1);

        await resolved.periodicallyShowNotification(
          id: 11,
          title: 'Daily Standup',
          body: 'Join the meeting',
          repeatInterval: RepeatInterval.daily,
        );
        expect(mockService.scheduledNotifications.length, 2);

        final pending = await resolved.getPendingNotificationRequests();
        expect(pending.length, 1);

        await resolved.cancelNotification(10);
        expect(mockService.scheduledNotifications.length, 1);

        // B: Actionable
        await resolved.showLocalNotification(
          id: 20,
          title: 'New Invite',
          body: 'Join team',
          actions: [
            const NotificationAction(id: 'accept', title: 'Accept'),
            const NotificationAction(
              id: 'decline',
              title: 'Decline',
              isDestructive: true,
            ),
          ],
        );
        expect(mockService.shownLocalNotifications.length, 1);

        // C: Rich Media
        await resolved.showRichMediaNotification(
          id: 30,
          title: 'Special Offer',
          body: 'Tap to see picture',
          imageUrl: 'https://example.com/promo.jpg',
        );
        expect(mockService.richMediaNotifications.length, 1);
        expect(
          mockService.richMediaNotifications.first['imageUrl'],
          'https://example.com/promo.jpg',
        );

        // D: Badges
        await resolved.setBadgeCount(5);
        expect(mockService.badgeCount, 5);
        await resolved.clearBadge();
        expect(mockService.badgeCount, 0);

        // E: Grouping
        await resolved.showGroupedNotification(
          id: 40,
          title: 'Alice',
          body: 'Hey there!',
          groupKey: 'chat_group_1',
        );
        expect(mockService.groupedNotifications.length, 1);
        expect(
          mockService.groupedNotifications.first['groupKey'],
          'chat_group_1',
        );
      },
    );
  });
}
