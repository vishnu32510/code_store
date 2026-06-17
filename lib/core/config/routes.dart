import '../di/injection.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/flashlight/flashlight_screen.dart';
import '../../features/home/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String dashboard = '/dashboard';
  static const String flashlight = '/flashlight';
  static const String login = '/login';
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
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (_, __) => AppRoutes.dashboard,
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
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
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardProfileView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _flashlightShellKey,
            routes: [
              GoRoute(
                path: AppRoutes.flashlight,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FlashlightScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
