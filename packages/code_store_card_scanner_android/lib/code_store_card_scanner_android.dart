import 'package:code_store_card_scanner_platform_interface/code_store_card_scanner_platform_interface.dart';
import 'package:flutter/services.dart';

/// The Android implementation of [CardScannerPlatform] using native Google Play Services ML Kit.
class CardScannerAndroid extends CardScannerPlatform {
  static const MethodChannel _channel =
      MethodChannel('com.nungu.codestore/card_scanner_android');

  /// Registers this class as the default instance of [CardScannerPlatform].
  static void registerWith() {
    CardScannerPlatform.instance = CardScannerAndroid();
  }

  @override
  Future<List<String>> processCameraFrame(CardCameraFrame frame) async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod<List<dynamic>>(
        'processFrame',
        <String, dynamic>{
          'bytes': frame.bytes,
          'width': frame.width,
          'height': frame.height,
          'rotation': frame.rotationDegrees,
        },
      );
      if (result == null) return <String>[];
      return result.cast<String>();
    } catch (_) {
      return <String>[];
    }
  }

  @override
  void dispose() {
    _channel.invokeMethod<void>('dispose');
  }
}
