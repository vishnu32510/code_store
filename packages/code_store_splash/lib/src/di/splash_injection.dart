import 'package:get_it/get_it.dart';

import '../services/i_splash_service.dart';
import '../services/splash_audio_player.dart';
import '../services/splash_service.dart';

/// Configures dependency injection registration for [ISplashService].
void setupSplashDI({
  GetIt? locator,
  ISplashService? customService,
  ISplashAudioPlayer? audioPlayer,
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<ISplashService>()) {
      di.registerSingleton<ISplashService>(customService);
    }
    return;
  }

  if (!di.isRegistered<ISplashService>()) {
    final service = SplashService(audioPlayer: audioPlayer);
    di.registerLazySingleton<ISplashService>(() => service);

    if (!di.isRegistered<SplashService>()) {
      di.registerLazySingleton<SplashService>(() => service);
    }
  }
}
