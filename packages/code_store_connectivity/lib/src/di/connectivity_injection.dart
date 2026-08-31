import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../services/connectivity_service.dart';
import '../services/i_connectivity_service.dart';

/// Registers [IConnectivityService] into the dependency injection locator.
void setupConnectivityDI({
  GetIt? locator,
  Connectivity? connectivity,
  IConnectivityService? customService,
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<IConnectivityService>()) {
      di.registerSingleton<IConnectivityService>(customService);
    }
    return;
  }

  if (!di.isRegistered<IConnectivityService>()) {
    final service = ConnectivityService(connectivity: connectivity);
    di.registerLazySingleton<IConnectivityService>(() => service);

    if (!di.isRegistered<ConnectivityService>()) {
      di.registerLazySingleton<ConnectivityService>(() => service);
    }
  }
}
