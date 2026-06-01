import 'package:code_store/core/config/global_keys.dart';
import 'package:code_store/core/services/services_barrel.dart';
import 'package:code_store/features/theme/theme_bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDI() {
  if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) {
    getIt.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
  }
  if (!getIt.isRegistered<GlobalKey<ScaffoldMessengerState>>()) {
    getIt.registerSingleton<GlobalKey<ScaffoldMessengerState>>(
      scaffoldMessengerKey,
    );
  }

  getIt.registerLazySingleton<DownloadService>(() => DownloadService());
  getIt.registerLazySingleton<OpenLinkService>(() => OpenLinkService());
  getIt.registerLazySingleton<HttpServices>(() => HttpServices());

  getIt.registerLazySingleton<IToastService>(
    () =>
        ToastService(messengerKey: getIt<GlobalKey<ScaffoldMessengerState>>()),
  );

  getIt.registerFactory<ThemeBloc>(() => ThemeBloc());
}
