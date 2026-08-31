import 'package:code_store_local_notifications/code_store_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalNotificationPayload & Action Tests', () {
    test('Payload serializes and deserializes correctly', () {
      final now = DateTime.now();
      final payload = LocalNotificationPayload(
        id: 'msg_101',
        title: 'Alarm Triggered',
        body: 'Time to review your tasks.',
        imageUrl: 'https://example.com/pic.jpg',
        data: {'route': '/notifications', 'priority': 'urgent'},
        sentTime: now,
        category: 'reminders',
      );

      final map = payload.toMap();
      expect(map['id'], 'msg_101');
      expect(map['title'], 'Alarm Triggered');
      expect(map['body'], 'Time to review your tasks.');
      expect(map['imageUrl'], 'https://example.com/pic.jpg');
      expect(payload.routePath, '/notifications');

      final fromMap = LocalNotificationPayload.fromMap(map);
      expect(fromMap.id, payload.id);
      expect(fromMap.title, payload.title);
      expect(fromMap.body, payload.body);
      expect(fromMap.imageUrl, payload.imageUrl);
      expect(fromMap.routePath, '/notifications');
    });

    test('LocalNotificationAction serialization works correctly', () {
      const action = LocalNotificationAction(
        id: 'reply_action',
        title: 'Reply',
        allowFreeFormInput: true,
        inputPlaceholder: 'Type response...',
      );

      final map = action.toMap();
      expect(map['id'], 'reply_action');
      expect(map['title'], 'Reply');
      expect(map['allowFreeFormInput'], true);
      expect(map['inputPlaceholder'], 'Type response...');

      final fromMap = LocalNotificationAction.fromMap(map);
      expect(fromMap.id, 'reply_action');
      expect(fromMap.title, 'Reply');
      expect(fromMap.allowFreeFormInput, true);
    });

    test('LocalNotificationActionResponse handles text and payload', () {
      final response = LocalNotificationActionResponse(
        actionId: 'snooze_5m',
        userText: 'Remind me later',
        payload: const LocalNotificationPayload(
          id: '123',
          title: 'Meeting',
          body: 'Standup',
        ),
      );

      final map = response.toMap();
      expect(map['actionId'], 'snooze_5m');
      expect(map['userText'], 'Remind me later');
      expect(map['payload'], isA<Map>());

      final fromMap = LocalNotificationActionResponse.fromMap(map);
      expect(fromMap.actionId, 'snooze_5m');
      expect(fromMap.userText, 'Remind me later');
      expect(fromMap.payload?.title, 'Meeting');
    });
  });
}
