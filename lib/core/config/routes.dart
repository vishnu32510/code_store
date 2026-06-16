import '../di/injection.dart';
import '../../features/flashlight/flashlight_screen.dart';
import '../../features/home/dashboard_screen.dart';
import '../../features/authentication/authentication.dart';
import '../../features/authentication/authentication_enums.dart';
import '../../features/authentication/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String flashlight = '/flashlight';
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      getIt<GlobalKey<NavigatorState>>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      // Global redirect protects all routes (e.g. deep links)
      final authBloc = context.read<AuthenticationBloc>();

      final signedIn =
          authBloc.state.status == AuthenticationStatus.authenticated &&
          authBloc.state.user.isNotEmpty;
      final loggingIn = state.matchedLocation == AppRoutes.login;

      if (!signedIn && !loggingIn) {
        return AppRoutes.login;
      }
      if (signedIn && loggingIn) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: <RouteBase>[
      // The home screen acts as the initial entry point.
      GoRoute(
        path: AppRoutes.home,
        redirect: (context, state) => AppRoutes.dashboard,
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // The StatefulShellRoute handles the BottomNavigationBar and its tabs.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // The DashboardScreen acts as the scaffold with the bottom nav bar.
          return DashboardScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardProfileView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.flashlight,
                builder: (context, state) => const FlashlightScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
