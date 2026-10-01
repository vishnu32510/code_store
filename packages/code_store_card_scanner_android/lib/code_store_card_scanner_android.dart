import 'dart:ui';

import 'package:code_store_card_scanner_platform_interface/code_store_card_scanner_platform_interface.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// The Android implementation of [CardScannerPlatform] using Google ML Kit.
class CardScannerAndroid extends CardScannerPlatform {
  /// Registers this class as the default instance of [CardScannerPlatform].
  static void registerWith() {
    CardScannerPlatform.instance = CardScannerAndroid();
  }

  TextRecognizer? _textRecognizer;

  TextRecognizer get _recognizer =>
      _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<List<String>> processCameraFrame(CardCameraFrame frame) async {
    final InputImageRotation rotation;
    switch (frame.rotationDegrees) {
      case 0:
        rotation = InputImageRotation.rotation0deg;
        break;
      case 90:
        rotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        rotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation270deg;
        break;
      default:
        rotation = InputImageRotation.rotation0deg;
        break;
    }

    final inputImage = InputImage.fromBytes(
      bytes: frame.bytes,
      metadata: InputImageMetadata(
        size: Size(frame.width.toDouble(), frame.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: frame.bytesPerRow ?? (frame.width),
      ),
    );

    final textR = await _recognizer.processImage(inputImage);
    final List<String> rawLines = [];
    for (final block in textR.blocks) {
      for (final line in block.lines) {
        final trimmed = line.text.trim();
        if (trimmed.isNotEmpty) {
          rawLines.add(trimmed);
        }
      }
    }
    return rawLines;
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
