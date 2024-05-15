import 'package:code_store/core/utils/app_constants.dart';
import 'package:code_store/modules/authentication/signup_bloc/signup_bloc.dart';
import 'package:code_store/modules/authentication/wrappers/auhentication_wrapper.dart';
import 'package:code_store/modules/authentication/authentication_bloc/authentication_bloc.dart';
import 'package:code_store/modules/authentication/wrappers/authentication_listner_wrapper.dart';
import 'package:code_store/modules/theme/theme_bloc/theme_bloc.dart';
import 'package:code_store/modules/theme/theme_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  /// `runApp(const MyApp());` is the entry point of a Flutter application. It tells Flutter to start
  /// running the app by creating an instance of the `MyApp` widget and rendering it on the screen. In
  /// this case, `MyApp` is a stateless widget that represents the root of the application. The `const`
  /// keyword is used to create a compile-time constant widget, which can help with performance
  /// optimizations.
  /// `runApp(const MyApp());` is the entry point of a Flutter application. It tells Flutter to start
  /// running the app by creating an instance of the `MyApp` widget and rendering it on the screen. In
  /// this case, `MyApp` is a stateless widget that represents the root of the application. The `const`
  /// keyword is used to create a compile-time constant widget, which can help with performance
  /// optimizations.
  runApp(const ThemeWrapper(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return AuthenticationWrapper(
          navigatorKey: _navigatorKey,
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            title: AppConstants.appTitle,
            theme: state.themeData,
            themeAnimationCurve: Curves.easeIn,
            themeAnimationDuration: const Duration(milliseconds: 500),
            themeMode: state.themeMode,
            darkTheme: DarkThemeState.darkTheme.themeData,
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _light() {
    BlocProvider.of<ThemeBloc>(context).add(ThemeEventChange(ThemeEventType.lightMode));
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticationListnerWrapper(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "userId",
              ),
              FloatingActionButton(
                onPressed: () {
                  BlocProvider.of<ThemeBloc>(context).add(ThemeEventChange(ThemeEventType.darkMode));
                  context.read<SignupBloc>().add(const SignupSubmitted());
                },
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
              FloatingActionButton(
                onPressed: () {
                  {
                    BlocProvider.of<ThemeBloc>(context)
                        .add(ThemeEventChange(ThemeEventType.system));
                    context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
                  }
                },
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _light,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
