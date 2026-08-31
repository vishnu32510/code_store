import 'package:get_it/get_it.dart';

import '../services/i_permission_service.dart';
import '../services/permission_service.dart';

/// Registers [IPermissionService] into the dependency injection locator.
void setupPermissionsDI({
  GetIt? locator,
  IPermissionService? customService,
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<IPermissionService>()) {
      di.registerSingleton<IPermissionService>(customService);
    }
    return;
  }

  if (!di.isRegistered<IPermissionService>()) {
    const service = PermissionService();
    di.registerLazySingleton<IPermissionService>(() => service);

    if (!di.isRegistered<PermissionService>()) {
      di.registerLazySingleton<PermissionService>(() => service);
    }
  }
}
