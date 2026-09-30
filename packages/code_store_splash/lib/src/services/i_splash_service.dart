import 'package:flutter/widgets.dart';

import '../models/splash_audio_config.dart';

/// Abstract service interface governing native splash screen retention, removal,
/// and optional audio chime playback.
abstract interface class ISplashService {
  /// Preserves the native splash screen until [remove] is called.
  /// Typically invoked before `runApp()` in `main()`.
  Future<void> preserve({WidgetsBinding? widgetsBinding});

  /// Dismisses the native splash screen, revealing the Flutter view underneath.
  Future<void> remove();

  /// Plays an audio chime/tune according to [config].
  Future<void> playChime({required SplashAudioConfig config});

  /// Immediately terminates any currently playing splash audio chime.
  Future<void> stopChime();

  /// Whether the current platform supports native OS splash screen preservation.
  bool get isNativeSupported;

  /// Releases audio and platform channel resources.
  void dispose();
}
