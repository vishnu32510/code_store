import 'package:code_store/core/config/routes.dart';
import 'package:code_store/features/flashlight/flashlight_control_service.dart';
import 'package:code_store_analytics/code_store_analytics.dart';
import 'package:code_store_biometrics/code_store_biometrics.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_home_widget/code_store_home_widget.dart';
import 'package:code_store_messaging/code_store_messaging.dart';
import 'package:code_store_permissions/code_store_permissions.dart';
import 'package:flutter/widgets.dart';

import '../utils/app_constants.dart';

Future<void> setupDI() async {
  // 1. Register package and feature singletons into GetIt
  setupCoreDI(defaultBaseUrl: AppConstants.baseUrl);
  setupAnalyticsDI();
  setupMessagingDI();
  setupBiometricsDI();
  setupPermissionsDI();
  setupHomeWidgetDI(
    appGroupId: AppConstants.appGroupId,
    defaultAndroidName: AppConstants.homeWidgetAndroidName,
    defaultIOSName: AppConstants.homeWidgetIOSName,
  );

  getIt.registerLazySingleton<FlashlightControlService>(
    () => FlashlightControlService(toast: getIt<IToastService>()),
  );

  // 2. Perform asynchronous startup initializations with centralized route navigation
  try {
    await getIt<HomeWidgetService>().initialize(
      onNavigate: (route) => AppRouter.router.go(route),
    );
  } catch (e) {
    debugPrint('Warning: HomeWidgetService initialization failed: $e');
  }

  try {
    await getIt<IMessagingService>().initialize(
      onNavigate: (route) => AppRouter.router.go(route),
    );
  } catch (e) {
    debugPrint('Warning: MessagingService initialization failed: $e');
  }
}
