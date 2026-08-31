import 'package:code_store/core/config/routes.dart';
import 'package:code_store/features/flashlight/flashlight_control_service.dart';
import 'package:code_store_analytics/code_store_analytics.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_home_widget/code_store_home_widget.dart';
import 'package:code_store_messaging/code_store_messaging.dart';
import 'package:flutter/widgets.dart';

import '../utils/app_constants.dart';

Future<void> setupDI() async {
  // 1. Register package and feature singletons into GetIt
  setupCoreDI(defaultBaseUrl: AppConstants.baseUrl);
  setupAnalyticsDI();
  setupMessagingDI();
  setupHomeWidgetDI(
    appGroupId: AppConstants.appGroupId,
    defaultAndroidName: AppConstants.homeWidgetAndroidName,
    defaultIOSName: AppConstants.homeWidgetIOSName,
  );

  getIt.registerLazySingleton<FlashlightControlService>(
    () => FlashlightControlService(toast: getIt<IToastService>()),
  );

  // 2. Perform asynchronous startup initializations for registered services
  try {
    final homeWidgetService = getIt<HomeWidgetService>();
    await homeWidgetService.initialize();

    // Listen for widget click actions while app is running
    homeWidgetService.onActionTriggered.listen((action) {
      _handleWidgetAction(action);
    });

    // Check if app was cold-started from a home screen widget
    final initialAction = await homeWidgetService.getInitialAction();
    if (initialAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleWidgetAction(initialAction);
      });
    }
  } catch (e) {
    debugPrint('Warning: HomeWidgetService initialization failed: $e');
  }

  try {
    await getIt<IMessagingService>().initialize(
      onNotificationTapped: (payload) {
        final rawRoute = payload.data['route'] ?? payload.data['payload'];
        if (rawRoute != null && rawRoute.toString().isNotEmpty) {
          final target = rawRoute.toString();
          AppRouter.router.go(target.startsWith('/') ? target : '/$target');
        } else {
          AppRouter.router.go(AppRoutes.notifications);
        }
      },
    );
  } catch (e) {
    debugPrint('Warning: MessagingService initialization failed: $e');
  }
}

void _handleWidgetAction(WidgetAction action) {
  final path = action.uri.path;
  final host = action.uri.host;
  final raw = path.isNotEmpty
      ? path
      : (host.isNotEmpty ? '/$host' : AppRoutes.homeWidget);

  // Normalize common target paths
  if (raw == '/notifications' || raw == 'notifications') {
    AppRouter.router.go(AppRoutes.notifications);
  } else if (raw == '/home-widget' || raw == 'home-widget') {
    AppRouter.router.go(AppRoutes.homeWidget);
  } else if (raw == '/flashlight' || raw == 'flashlight') {
    AppRouter.router.go(AppRoutes.flashlight);
  } else if (raw == '/dashboard' || raw == 'dashboard') {
    AppRouter.router.go(AppRoutes.dashboard);
  } else if (raw == '/login' || raw == 'login') {
    AppRouter.router.go(AppRoutes.login);
  } else {
    // If unknown or custom, navigate to normalized path (GoRouter will route to NotFoundScreen if unmapped)
    AppRouter.router.go(raw.startsWith('/') ? raw : '/$raw');
  }
}
