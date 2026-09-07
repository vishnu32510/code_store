import 'package:get_it/get_it.dart';

import '../services/dynamic_island_service.dart';
import '../services/i_dynamic_island_service.dart';

/// Registers [IDynamicIslandService] into the GetIt service locator.
///
/// Pass a [customService] to override the default [DynamicIslandService]
/// for testing or platform-specific implementations.
void setupDynamicIslandDI({
  GetIt? locator,
  IDynamicIslandService? customService,
  String appGroupId = 'group.com.nungu.codestore',
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<IDynamicIslandService>()) {
      di.registerSingleton<IDynamicIslandService>(customService);
    }
    return;
  }

  if (!di.isRegistered<IDynamicIslandService>()) {
    final service = DynamicIslandService(appGroupId: appGroupId);
    di.registerLazySingleton<IDynamicIslandService>(() => service);

    if (!di.isRegistered<DynamicIslandService>()) {
      di.registerLazySingleton<DynamicIslandService>(() => service);
    }
  }
}
