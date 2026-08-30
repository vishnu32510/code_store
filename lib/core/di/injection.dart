import 'package:flutter/foundation.dart';
import 'package:code_store/features/flashlight/flashlight_control_service.dart';
import 'package:code_store_analytics/code_store_analytics.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_home_widget/code_store_home_widget.dart';
import 'package:code_store_messaging/code_store_messaging.dart';

import '../utils/app_constants.dart';

Future<void> setupDI() async {
  // 1. Register package and feature singletons into GetIt
  setupCoreDI(defaultBaseUrl: AppConstants.baseUrl);
  setupAnalyticsDI();
  setupMessagingDI();

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

  // 2. Perform asynchronous startup initializations for registered services
  try {
    await getIt<HomeWidgetService>().initialize(
      appGroupId: AppConstants.appGroupId,
      defaultAndroidName: AppConstants.homeWidgetAndroidName,
      defaultIOSName: AppConstants.homeWidgetIOSName,
    );
  } catch (e) {
    debugPrint('Warning: HomeWidgetService initialization failed: $e');
  }

  try {
    await getIt<IMessagingService>().initialize();
  } catch (e) {
    debugPrint('Warning: MessagingService initialization failed: $e');
  }
}
