import 'package:get_it/get_it.dart';

import '../services/i_share_service.dart';
import '../services/share_service.dart';

/// Registers [IShareService] into the dependency injection locator.
void setupShareDI({
  GetIt? locator,
  IShareService? customService,
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<IShareService>()) {
      di.registerSingleton<IShareService>(customService);
    }
    return;
  }

  if (!di.isRegistered<IShareService>()) {
    const service = ShareService();
    di.registerLazySingleton<IShareService>(() => service);

    if (!di.isRegistered<ShareService>()) {
      di.registerLazySingleton<ShareService>(() => service);
    }
  }
}
