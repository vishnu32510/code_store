import 'dart:async';
import 'package:code_store_messaging/code_store_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockMessagingService implements IMessagingService {
  final _foregroundController =
      StreamController<PushNotificationPayload>.broadcast();
  final _openedAppController =
      StreamController<PushNotificationPayload>.broadcast();
  final _tokenRefreshController = StreamController<String>.broadcast();

  bool initialized = false;
  String? currentToken = 'mock_fcm_token_123';
  final List<String> subscribedTopics = [];
  final List<Map<String, dynamic>> shownLocalNotifications = [];

  @override
  Stream<PushNotificationPayload> get onForegroundMessage =>
      _foregroundController.stream;

  @override
  Stream<PushNotificationPayload> get onMessageOpenedApp =>
      _openedAppController.stream;

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Future<void> initialize({
    bool showForegroundNotifications = true,
    String defaultAndroidIcon = '@mipmap/ic_launcher',
    String channelId = 'high_importance_channel',
    String channelName = 'High Importance Notifications',
    String channelDescription = 'This channel is used for important notifications.',
    NotificationTapHandler? onNotificationTapped,
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
  }) async {
    shownLocalNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'channelId': channelId,
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
    _tokenRefreshController.close();
  }
}

void main() {
  group('PushNotificationPayload Tests', () {
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
  });

  group('Messaging DI & Service Tests', () {
    late GetIt testLocator;

    setUp(() {
      testLocator = GetIt.asNewInstance();
    });

    test('Registers custom IMessagingService in GetIt DI properly', () async {
      final mockService = MockMessagingService();
      setupMessagingDI(locator: testLocator, customService: mockService);

      expect(testLocator.isRegistered<IMessagingService>(), isTrue);
      final resolved = testLocator<IMessagingService>();
      expect(resolved, isA<MockMessagingService>());

      await resolved.initialize();
      expect(mockService.initialized, isTrue);

      final token = await resolved.getToken();
      expect(token, 'mock_fcm_token_123');

      await resolved.subscribeToTopic('news');
      expect(mockService.subscribedTopics, contains('news'));

      await resolved.unsubscribeFromTopic('news');
      expect(mockService.subscribedTopics, isEmpty);

      final initialMsg = await resolved.getInitialMessage();
      expect(initialMsg?.title, 'Welcome Back');
    });
  });
}
