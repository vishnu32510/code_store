import 'bloc_observer.dart';
import 'core/config/global_keys.dart';
import 'core/config/routes.dart';
import 'core/di/injection.dart';
import 'core/utils/app_constants.dart';
import 'features/authentication/authentication.dart';
import 'features/theme/theme.dart';
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
