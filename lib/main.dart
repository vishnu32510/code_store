import 'package:code_store/bloc_observer.dart';
import 'package:code_store/core/config/global_keys.dart';
import 'package:code_store/core/config/routes.dart';
import 'package:code_store/core/di/injection.dart';
import 'package:code_store/core/utils/app_constants.dart';
import 'package:code_store/features/authentication/authentication.dart';
import 'package:code_store/features/theme/theme.dart';
import 'package:code_store/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env not found or failed to load: $e');
  }
  Bloc.observer = SimpleBlocObserver();
  setupDI();
  runApp(
    const AuthenticationWrapper(child: ThemeWrapper(child: CodeStoreApp())),
  );
}

class CodeStoreApp extends StatelessWidget {
  const CodeStoreApp({super.key});

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
          darkTheme: DarkThemeState.darkTheme.themeData,
          themeAnimationCurve: Curves.easeIn,
          themeAnimationDuration: const Duration(milliseconds: 500),
        );
      },
    );
  }
}
