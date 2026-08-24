import 'package:code_store/features/flashlight/flashlight_control_service.dart';
import 'package:code_store_core/code_store_core.dart';
import '../utils/app_constants.dart';

void setupDI() {
  // Initialize core package singletons (Toast, HTTP, Gal, Keys)
  setupCoreDI(defaultBaseUrl: AppConstants.baseUrl);
  getIt.registerLazySingleton<FlashlightControlService>(
    () => FlashlightControlService(toast: getIt<IToastService>()),
  );
}
