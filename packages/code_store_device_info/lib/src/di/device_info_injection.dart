import 'package:get_it/get_it.dart';

import '../services/device_info_service.dart';
import '../services/i_device_info_service.dart';

/// Registers [IDeviceInfoService] into the dependency injection locator.
void setupDeviceInfoDI({GetIt? locator, IDeviceInfoService? customService}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<IDeviceInfoService>()) {
      di.registerSingleton<IDeviceInfoService>(customService);
    }
    return;
  }

  if (!di.isRegistered<IDeviceInfoService>()) {
    final service = DeviceInfoService();
    di.registerLazySingleton<IDeviceInfoService>(() => service);

    if (!di.isRegistered<DeviceInfoService>()) {
      di.registerLazySingleton<DeviceInfoService>(() => service);
    }
  }
}
