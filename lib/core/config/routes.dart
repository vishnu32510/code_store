import 'package:code_store_analytics/code_store_analytics.dart';
import 'package:code_store_auth/code_store_auth.dart';
import 'package:code_store_core/code_store_core.dart';

import '../../features/flashlight/flashlight_screen.dart';
import '../../features/home/dashboard_screen.dart';
import '../../features/home_widget/home_widget_screen.dart';
import '../../features/notifications/notifications_screen.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String dashboard = '/dashboard';
  static const String flashlight = '/flashlight';
  static const String homeWidget = '/home-widget';
  static const String login = '/login';
  static const String notifications = '/notifications';
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      getIt<GlobalKey<NavigatorState>>();

  static final GlobalKey<NavigatorState> _dashboardShellKey =
      GlobalKey<NavigatorState>(debugLabel: 'dashboardShell');

  static final GlobalKey<NavigatorState> _flashlightShellKey =
      GlobalKey<NavigatorState>(debugLabel: 'flashlightShell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    observers: [getIt<FirebaseAnalyticsObserver>()],
    routes: <RouteBase>[
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.dashboard),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.homeWidget,
        builder: (context, state) => const HomeWidgetScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardShellKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardProfileView()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _flashlightShellKey,
            routes: [
              GoRoute(
                path: AppRoutes.flashlight,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: FlashlightScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
