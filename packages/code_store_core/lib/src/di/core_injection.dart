import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../config/global_keys.dart';
import '../services/download_service.dart';
import '../services/open_link_service.dart';
import '../services/services.dart';
import '../services/toast_service.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Registers all core services and global keys in GetIt.
/// Pass an optional [locator] or it will use `getIt` (GetIt.instance).
void setupCoreDI({GetIt? locator, String? defaultBaseUrl}) {
  final di = locator ?? getIt;

  if (!di.isRegistered<GlobalKey<NavigatorState>>()) {
    di.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
  }
  if (!di.isRegistered<GlobalKey<ScaffoldMessengerState>>()) {
    di.registerSingleton<GlobalKey<ScaffoldMessengerState>>(
      scaffoldMessengerKey,
    );
  }

  if (!di.isRegistered<DownloadService>()) {
    di.registerLazySingleton<DownloadService>(() => DownloadService());
  }
  if (!di.isRegistered<OpenLinkService>()) {
    di.registerLazySingleton<OpenLinkService>(() => OpenLinkService());
  }
  if (!di.isRegistered<HttpServices>()) {
    di.registerLazySingleton<HttpServices>(
      () => HttpServices(baseUrl: defaultBaseUrl),
    );
  }
  if (!di.isRegistered<IToastService>()) {
    di.registerLazySingleton<IToastService>(
      () => ToastService(messengerKey: di<GlobalKey<ScaffoldMessengerState>>()),
    );
  }
}
