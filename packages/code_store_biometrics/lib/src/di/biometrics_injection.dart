import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';

import '../services/biometric_service.dart';
import '../services/i_biometric_service.dart';

/// Registers the [IBiometricService] singleton into [GetIt].
void setupBiometricsDI({
  GetIt? locator,
  LocalAuthentication? localAuth,
  IBiometricService? customService,
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<IBiometricService>()) {
      di.registerSingleton<IBiometricService>(customService);
    }
    return;
  }

  if (!di.isRegistered<IBiometricService>()) {
    final service = BiometricService(localAuth: localAuth);
    di.registerLazySingleton<IBiometricService>(() => service);

    if (!di.isRegistered<BiometricService>()) {
      di.registerLazySingleton<BiometricService>(() => service);
    }
  }
}
