import 'package:code_store/core/utils/app_constants.dart';
import 'package:code_store/theme/theme_bloc/theme_bloc.dart';
import 'package:code_store/theme/theme_wrapper.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: AppConstants.appTitle,
          theme: state.themeData,
          themeAnimationCurve: Curves.easeIn,
          themeAnimationDuration: const Duration(milliseconds: 500),
          themeMode: state.themeMode,
          darkTheme: ThemeState.darkTheme.themeData,
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _light() {
    BlocProvider.of<ThemeBloc>(context).add(ThemeEventChange(ThemeEventType.lightMode));
  }

  void _system() {
    BlocProvider.of<ThemeBloc>(context).add(ThemeEventChange(ThemeEventType.system));
  }

  void _dark() {
    BlocProvider.of<ThemeBloc>(context).add(ThemeEventChange(ThemeEventType.darkMode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            FloatingActionButton(
              onPressed: _dark,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: _system,
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
    );
  }
}
