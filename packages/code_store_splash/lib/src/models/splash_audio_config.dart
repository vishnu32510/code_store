import 'package:meta/meta.dart';

/// Configuration for audio tunes, chimes, or jingles played during the splash screen.
@immutable
class SplashAudioConfig {
  const SplashAudioConfig({
    required this.assetPath,
    this.volume = 1.0,
    this.delay = Duration.zero,
    this.loop = false,
    this.enabled = true,
  }) : assert(
         volume >= 0.0 && volume <= 1.0,
         'Volume must be between 0.0 and 1.0',
       );

  /// Flutter asset path for the audio chime (e.g. 'assets/audio/splash_chime.wav' or 'packages/code_store_splash/assets/audio/chime.wav').
  final String assetPath;

  /// Playback volume from 0.0 (silent) to 1.0 (full).
  final double volume;

  /// Delay duration before triggering audio playback after splash view mounts.
  final Duration delay;

  /// Whether the audio should loop continuously while splash is displayed.
  final bool loop;

  /// Master switch to enable or mute audio playback.
  final bool enabled;

  /// Convenience factory for a muted configuration.
  factory SplashAudioConfig.muted({String assetPath = ''}) {
    return SplashAudioConfig(assetPath: assetPath, enabled: false);
  }

  SplashAudioConfig copyWith({
    String? assetPath,
    double? volume,
    Duration? delay,
    bool? loop,
    bool? enabled,
  }) {
    return SplashAudioConfig(
      assetPath: assetPath ?? this.assetPath,
      volume: volume ?? this.volume,
      delay: delay ?? this.delay,
      loop: loop ?? this.loop,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assetPath': assetPath,
      'volume': volume,
      'delayMs': delay.inMilliseconds,
      'loop': loop,
      'enabled': enabled,
    };
  }

  factory SplashAudioConfig.fromMap(Map<String, dynamic> map) {
    return SplashAudioConfig(
      assetPath: map['assetPath'] as String? ?? '',
      volume: (map['volume'] as num?)?.toDouble() ?? 1.0,
      delay: Duration(milliseconds: map['delayMs'] as int? ?? 0),
      loop: map['loop'] as bool? ?? false,
      enabled: map['enabled'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashAudioConfig &&
          runtimeType == other.runtimeType &&
          assetPath == other.assetPath &&
          volume == other.volume &&
          delay == other.delay &&
          loop == other.loop &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(assetPath, volume, delay, loop, enabled);

  @override
  String toString() =>
      'SplashAudioConfig(assetPath: $assetPath, volume: $volume, delay: ${delay.inMilliseconds}ms, loop: $loop, enabled: $enabled)';
}
