import 'package:code_store/features/flashlight/flashlight_control_service.dart';
import 'package:code_store_analytics/code_store_analytics.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_home_widget/code_store_home_widget.dart';

import '../utils/app_constants.dart';

void setupDI() {
  // Initialize core package singletons (Toast, HTTP, Gal, Keys)
  setupCoreDI(defaultBaseUrl: AppConstants.baseUrl);
  setupAnalyticsDI();
  getIt.registerLazySingleton<FlashlightControlService>(
    () => FlashlightControlService(toast: getIt<IToastService>()),
  );
  getIt.registerLazySingleton<HomeWidgetService>(
    () => HomeWidgetService(
      appGroupId: AppConstants.appGroupId,
      defaultAndroidName: AppConstants.homeWidgetAndroidName,
      defaultIOSName: AppConstants.homeWidgetIOSName,
    ),
  );
}
