library;

// Dependency Injection
export 'src/di/splash_injection.dart';

// Models
export 'src/models/splash_animation_type.dart';
export 'src/models/splash_audio_config.dart';
export 'src/models/splash_config.dart';
export 'src/models/splash_result.dart';

// Services & Audio
export 'src/services/i_splash_service.dart';
export 'src/services/splash_audio_player.dart';
export 'src/services/splash_service.dart';

// Utilities
export 'src/utils/native_splash_config_helper.dart';

// Widgets
export 'src/widgets/animated_splash_logo.dart';
export 'src/widgets/native_splash_view.dart';
export 'src/widgets/splash_footer_logo.dart';

// Third-Party Re-exports
export 'package:flutter_native_splash/flutter_native_splash.dart'
    show FlutterNativeSplash;
