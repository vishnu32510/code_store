import 'dart:typed_data';

import 'package:code_store_card_scanner_platform_interface/code_store_card_scanner_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class TestCardScannerPlatform extends CardScannerPlatform {
  @override
  Future<List<String>> processCameraFrame(CardCameraFrame frame) async {
    return ['4532 1234 5678 9012', '12/28'];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CardCameraFrame', () {
    test('constructs and holds properties accurately', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final frame = CardCameraFrame(
        bytes: bytes,
        width: 1920,
        height: 1080,
        rotationDegrees: 90,
        bytesPerRow: 1920,
      );

      expect(frame.bytes, equals(bytes));
      expect(frame.width, equals(1920));
      expect(frame.height, equals(1080));
      expect(frame.rotationDegrees, equals(90));
      expect(frame.bytesPerRow, equals(1920));
    });
  });

  group('CardScannerPlatform', () {
    test('default instance is MethodChannelCardScanner', () {
      expect(CardScannerPlatform.instance, isA<CardScannerPlatform>());
    });

    test('default implementation returns empty list for processCameraFrame',
        () async {
      final frame = CardCameraFrame(
        bytes: Uint8List(0),
        width: 100,
        height: 100,
        rotationDegrees: 0,
      );
      final result =
          await CardScannerPlatform.instance.processCameraFrame(frame);
      expect(result, isEmpty);
    });

    test('custom implementation can be set and invoked', () async {
      final custom = TestCardScannerPlatform();
      CardScannerPlatform.instance = custom;
      expect(CardScannerPlatform.instance, equals(custom));

      final frame = CardCameraFrame(
        bytes: Uint8List(0),
        width: 100,
        height: 100,
        rotationDegrees: 0,
      );
      final lines =
          await CardScannerPlatform.instance.processCameraFrame(frame);
      expect(lines, contains('4532 1234 5678 9012'));
    });
  });
}
