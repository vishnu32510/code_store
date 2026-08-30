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
    themeData: ThemeData.dark(useMaterial3: true)
        .copyWith(colorScheme: const ColorScheme.dark()),
    themeMode: ThemeMode.dark,
  );

  static AppThemeConfig get light => AppThemeConfig(
    id: 'light',
    name: 'Light',
    icon: Icons.wb_sunny_rounded,
    themeData: ThemeData.light(useMaterial3: true)
        .copyWith(colorScheme: const ColorScheme.light()),
    themeMode: ThemeMode.light,
  );

  static AppThemeConfig get system => AppThemeConfig(
    id: 'system',
    name: 'System',
    icon: Icons.sync_sharp,
    themeData: ThemeData.light(useMaterial3: true)
        .copyWith(colorScheme: const ColorScheme.light()),
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

  static AppThemeConfig get plushie => AppThemeConfig(
    id: 'plushie',
    name: 'Warm Plushie',
    icon: Icons.pets_rounded,
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFD4A047),
        onPrimary: Colors.white,
        secondary: Color(0xFF8B6340),
        onSecondary: Colors.white,
        surface: Color(0xFFFFFBF2),
        onSurface: Color(0xFF3D2B1F),
        surfaceContainerHighest: Color(0xFFF5E6C8),
        outline: Color(0xFFE8DCC8),
      ),
      scaffoldBackgroundColor: const Color(0xFFFAF0DC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAF0DC),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF3D2B1F)),
        titleTextStyle: TextStyle(
          color: Color(0xFF3D2B1F),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3D2B1F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFBF2),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8DCC8), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFBF2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD4A047), width: 1.8),
        ),
      ),
    ),
    themeMode: ThemeMode.light,
  );

  static AppThemeConfig get plushieDark => AppThemeConfig(
    id: 'plushie_dark',
    name: 'Plushie Dark',
    icon: Icons.nightlight_outlined,
    themeData: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF1A1208),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD4A047),
        onPrimary: Colors.white,
        secondary: Color(0xFF8B6340),
        surface: Color(0xFF2A1F14),
        onSurface: Color(0xFFF5E6C8),
        surfaceContainerHighest: Color(0xFF3D2B1F),
        outline: Color(0xFF5C3D1E),
      ),
    ),
    themeMode: ThemeMode.dark,
  );

  static List<AppThemeConfig> get defaultThemes => [
    dark,
    light,
    plushie,
    plushieDark,
    system,
    amoled,
  ];
}
