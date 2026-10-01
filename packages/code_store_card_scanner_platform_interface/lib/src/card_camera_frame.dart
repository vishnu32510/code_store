import 'dart:typed_data';

/// Encapsulates raw camera image frame bytes and orientation parameters
/// for platform OCR processors (Apple Vision on iOS, Google ML Kit on Android).
class CardCameraFrame {
  const CardCameraFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.rotationDegrees,
    this.bytesPerRow,
  });

  /// The raw image bytes (e.g. BGRA8888 on iOS, NV21 on Android).
  final Uint8List bytes;

  /// Width in pixels.
  final int width;

  /// Height in pixels.
  final int height;

  /// Sensor rotation in degrees (0, 90, 180, 270).
  final int rotationDegrees;

  /// Optional stride / bytes per row for row-aligned formats.
  final int? bytesPerRow;
}
