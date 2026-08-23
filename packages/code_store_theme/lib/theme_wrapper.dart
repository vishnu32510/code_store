import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'models/app_theme_config.dart';
import 'theme_bloc/theme_bloc.dart';

class ThemeWrapper extends StatelessWidget {
  final Widget child;
  final List<AppThemeConfig>? availableThemes;
  final String? initialThemeId;
  final ThemeBloc? themeBloc;

  const ThemeWrapper({
    super.key,
    required this.child,
    this.availableThemes,
    this.initialThemeId,
    this.themeBloc,
  });

  @override
  Widget build(BuildContext context) {
    if (themeBloc != null) {
      return BlocProvider<ThemeBloc>.value(
        value: themeBloc!,
        child: child,
      );
    }

    return BlocProvider<ThemeBloc>(
      create: (_) => ThemeBloc(
        availableThemes: availableThemes,
        initialThemeId: initialThemeId,
      ),
      child: child,
    );
  }
}
