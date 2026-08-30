import 'bloc_observer.dart';

import 'package:code_store_core/code_store_core.dart';

import 'core/config/routes.dart';
import 'core/di/injection.dart';
import 'core/utils/app_constants.dart';

import 'package:code_store_auth/code_store_auth.dart';
import 'package:code_store_theme/code_store_theme.dart';
import 'package:code_store_home_widget/code_store_home_widget.dart';

import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env not found or failed to load: $e');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = SimpleBlocObserver();
  setupDI();
  try {
    await getIt<HomeWidgetService>().initialize(
      appGroupId: AppConstants.appGroupId,
      defaultAndroidName: AppConstants.homeWidgetAndroidName,
      defaultIOSName: AppConstants.homeWidgetIOSName,
    );
  } catch (e) {
    debugPrint('Warning: HomeWidgetService initialization failed: $e');
  }
  runApp(const AuthenticationWrapper(child: ThemeWrapper(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: AppConstants.appTitle,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: themeState.themeData,
          themeMode: themeState.themeMode,
          darkTheme: AppThemeConfig.dark.themeData,
          themeAnimationCurve: Curves.easeIn,
          themeAnimationDuration: const Duration(milliseconds: 500),
          builder: (context, child) {
            if (child == null) {
              return const ColoredBox(color: Colors.black);
            }
            return AuthenticationListenerWrapper(child: child);
          },
        );
      },
    );
  }
}
