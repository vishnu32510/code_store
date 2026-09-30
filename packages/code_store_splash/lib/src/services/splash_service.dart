import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../models/splash_audio_config.dart';
import 'i_splash_service.dart';
import 'splash_audio_player.dart';

/// Concrete implementation of [ISplashService] coordinating native splash screen
/// bridge calls (Android/iOS) and audio chime playback.
class SplashService implements ISplashService {
  SplashService({ISplashAudioPlayer? audioPlayer})
    : _audioPlayer = audioPlayer ?? AudioplayersSplashAudioPlayer();

  final ISplashAudioPlayer _audioPlayer;
  bool _isPreserved = false;

  /// Whether the native splash screen is currently preserved.
  bool get isPreserved => _isPreserved;

  @override
  bool get isNativeSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Future<void> preserve({WidgetsBinding? widgetsBinding}) async {
    if (!isNativeSupported) return;
    try {
      final binding = widgetsBinding ?? WidgetsBinding.instance;
      FlutterNativeSplash.preserve(widgetsBinding: binding);
      _isPreserved = true;
    } catch (e) {
      debugPrint('[SplashService] Native splash preserve notice: $e');
    }
  }

  @override
  Future<void> remove() async {
    try {
      FlutterNativeSplash.remove();
      _isPreserved = false;
    } catch (e) {
      debugPrint('[SplashService] Native splash remove notice: $e');
    }
  }

  @override
  Future<void> playChime({required SplashAudioConfig config}) async {
    if (!config.enabled || config.assetPath.isEmpty) return;

    if (config.delay > Duration.zero) {
      await Future<void>.delayed(config.delay);
    }

    await _audioPlayer.playAsset(
      config.assetPath,
      volume: config.volume,
      loop: config.loop,
    );
  }

  @override
  Future<void> stopChime() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
  }
}
