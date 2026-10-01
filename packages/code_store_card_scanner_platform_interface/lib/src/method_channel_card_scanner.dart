import 'card_camera_frame.dart';
import 'card_scanner_platform.dart';

/// Fallback / default implementation of [CardScannerPlatform] when no platform-specific
/// plugin (iOS Apple Vision or Android ML Kit) is registered (e.g. desktop/web or tests).
class MethodChannelCardScanner extends CardScannerPlatform {
  @override
  Future<List<String>> processCameraFrame(CardCameraFrame frame) async {
    return const [];
  }

  @override
  void dispose() {}
}
