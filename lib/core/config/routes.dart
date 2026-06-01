import 'package:code_store/core/di/injection.dart';
import 'package:code_store/features/flashlight/flashlight_screen.dart';
import 'package:code_store/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String home = '/';
  static const String flashlight = '/flashlight';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: getIt<GlobalKey<NavigatorState>>(),
    initialLocation: AppRoutes.home,
    routes: <GoRoute>[
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.flashlight,
        builder: (context, state) => const FlashlightScreen(),
      ),
    ],
  );
}
