import 'dart:ui';

import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:apple_vision_recognize_text/apple_vision_recognize_text.dart'
    as apple;
import 'package:code_store_card_scanner_platform_interface/code_store_card_scanner_platform_interface.dart';

/// The iOS implementation of [CardScannerPlatform] using native Apple Vision (SPM).
class CardScannerIos extends CardScannerPlatform {
  /// Registers this class as the default instance of [CardScannerPlatform].
  static void registerWith() {
    CardScannerPlatform.instance = CardScannerIos();
  }

  apple.AppleVisionRecognizeTextController? _appleVision;

  apple.AppleVisionRecognizeTextController get _appleVisionController =>
      _appleVision ??= apple.AppleVisionRecognizeTextController();

  @override
  Future<List<String>> processCameraFrame(CardCameraFrame frame) async {
    final ImageOrientation appleOrient;
    switch (frame.rotationDegrees) {
      case 0:
        appleOrient = ImageOrientation.up;
        break;
      case 90:
        appleOrient = ImageOrientation.right;
        break;
      case 180:
        appleOrient = ImageOrientation.down;
        break;
      case 270:
        appleOrient = ImageOrientation.left;
        break;
      default:
        appleOrient = ImageOrientation.up;
        break;
    }

    final results = await _appleVisionController.processImage(
      apple.RecognizeTextData(
        automaticallyDetectsLanguage: false,
        languages: [const Locale('en', 'US')],
        recognitionLevel: apple.RecognitionLevel.accurate,
        image: frame.bytes,
        orientation: appleOrient,
        imageSize: Size(frame.width.toDouble(), frame.height.toDouble()),
      ),
    );

    final List<String> rawLines = [];
    if (results != null) {
      for (final item in results) {
        for (final line in item.listText) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty) {
            rawLines.add(trimmed);
          }
        }
      }
    }
    return rawLines;
  }

  @override
  void dispose() {
    _appleVision = null;
  }
}
