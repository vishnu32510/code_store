import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a dynamic theme configuration registered in [ThemeBloc].
@immutable
class AppThemeConfig extends Equatable {
  /// Unique identifier for this theme (e.g. 'dark', 'light', 'spider_man').
  final String id;

  /// Human-readable display name (e.g. 'Dark', 'Light', 'Amoled').
  final String name;

  /// Icon representing the theme. Can be [IconData] or custom [Widget].
  final dynamic icon;

  /// The complete [ThemeData] definition.
  final ThemeData themeData;

  /// The [ThemeMode] associated with this theme.
  final ThemeMode themeMode;

  const AppThemeConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.themeData,
    this.themeMode = ThemeMode.dark,
  });

  @override
  List<Object?> get props => [id, name, themeData, themeMode];

  // Universal Built-in Presets
  static AppThemeConfig get dark => AppThemeConfig(
        id: 'dark',
        name: 'Dark',
        icon: Icons.nightlight_round,
        themeData: ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(),
        ),
        themeMode: ThemeMode.dark,
      );

  static AppThemeConfig get light => AppThemeConfig(
        id: 'light',
        name: 'Light',
        icon: Icons.wb_sunny_rounded,
        themeData: ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(),
        ),
        themeMode: ThemeMode.light,
      );

  static AppThemeConfig get system => AppThemeConfig(
        id: 'system',
        name: 'System',
        icon: Icons.sync_sharp,
        themeData: ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(),
        ),
        themeMode: ThemeMode.system,
      );

  static AppThemeConfig get amoled => AppThemeConfig(
        id: 'amoled',
        name: 'Amoled',
        icon: Icons.brightness_2_rounded,
        themeData: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            surface: Colors.black,
            primary: Color(0xFF9936E2),
            secondary: Color(0xFF00E5FF),
          ),
        ),
        themeMode: ThemeMode.dark,
      );

  static List<AppThemeConfig> get defaultThemes => [dark, light, system, amoled];
}
