import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Contract for audio playback during the splash screen sequence.
abstract interface class ISplashAudioPlayer {
  /// Plays an audio asset with the specified volume and looping parameters.
  Future<void> playAsset(
    String assetPath, {
    double volume = 1.0,
    bool loop = false,
  });

  /// Stops current playback.
  Future<void> stop();

  /// Releases audio player resources.
  void dispose();
}

/// Production audio player implementation leveraging [AudioPlayer] from `package:audioplayers`.
class AudioplayersSplashAudioPlayer implements ISplashAudioPlayer {
  AudioplayersSplashAudioPlayer({AudioPlayer? player}) : _customPlayer = player;

  final AudioPlayer? _customPlayer;
  AudioPlayer? _lazyPlayer;

  AudioPlayer get _player => _customPlayer ?? (_lazyPlayer ??= AudioPlayer());

  @override
  Future<void> playAsset(
    String assetPath, {
    double volume = 1.0,
    bool loop = false,
  }) async {
    try {
      final player = _player;
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.release,
      );

      // Clean asset path (strip 'assets/' prefix if AudioPlayer AssetSource expects it without):
      final normalizedPath = assetPath.startsWith('assets/')
          ? assetPath.substring(7)
          : assetPath;

      await player.play(AssetSource(normalizedPath));
    } catch (e) {
      debugPrint('[SplashAudioPlayer] Audio playback notice: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      if (_customPlayer != null || _lazyPlayer != null) {
        await _player.stop();
      }
    } catch (e) {
      debugPrint('[SplashAudioPlayer] Audio stop notice: $e');
    }
  }

  @override
  void dispose() {
    try {
      if (_customPlayer != null || _lazyPlayer != null) {
        _player.dispose();
      }
    } catch (e) {
      debugPrint('[SplashAudioPlayer] Audio dispose notice: $e');
    }
  }
}
