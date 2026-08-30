import 'package:flutter_test/flutter_test.dart';
import 'package:code_store_home_widget/code_store_home_widget.dart';

void main() {
  group('HomeWidgetPayload', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime.now();
      final payload = HomeWidgetPayload(
        title: 'Daily Goal',
        message: '8 of 10 habits completed',
        status: 'Active',
        updatedAt: now,
        badgeCount: 3,
        actionUri: 'codestore://widgets/details',
        customData: const {'streak': 5},
      );

      final map = payload.toMap();
      expect(map['title'], 'Daily Goal');
      expect(map['message'], '8 of 10 habits completed');
      expect(map['status'], 'Active');
      expect(map['badgeCount'], 3);
      expect(map['actionUri'], 'codestore://widgets/details');
      expect(map['streak'], 5);

      final deserialized = HomeWidgetPayload.fromMap(map);
      expect(deserialized.title, payload.title);
      expect(deserialized.message, payload.message);
      expect(deserialized.status, payload.status);
      expect(deserialized.badgeCount, payload.badgeCount);
      expect(deserialized.actionUri, payload.actionUri);
    });
  });

  group('WidgetAction', () {
    test('parses action URI and parameters correctly', () {
      final uri = Uri.parse('codestore://weather?action=refresh&city=NYC');
      final action = WidgetAction.fromUri(uri);

      expect(action.uri, uri);
      expect(action.actionId, 'refresh');
      expect(action.parameters['city'], 'NYC');
    });

    test('falls back to host when action query parameter is missing', () {
      final uri = Uri.parse('codestore://dashboard');
      final action = WidgetAction.fromUri(uri);

      expect(action.actionId, 'dashboard');
    });
  });
}
