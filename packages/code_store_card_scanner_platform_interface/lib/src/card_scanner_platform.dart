import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'card_camera_frame.dart';
import 'method_channel_card_scanner.dart';

/// The interface that platform-specific implementations of `code_store_card_scanner` must extend.
abstract class CardScannerPlatform extends PlatformInterface {
  CardScannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static CardScannerPlatform _instance = MethodChannelCardScanner();

  /// The current default instance of [CardScannerPlatform] to use.
  static CardScannerPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [CardScannerPlatform] when they register themselves.
  static set instance(CardScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Processes a single camera frame to extract recognized lines of text.
  Future<List<String>> processCameraFrame(CardCameraFrame frame) {
    throw UnimplementedError('processCameraFrame() has not been implemented.');
  }

  /// Disposes any native resources, ML model sessions, or controllers.
  void dispose() {}
}
