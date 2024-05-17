part of 'theme_bloc.dart';

@immutable
class ThemeState extends Equatable {
  final ThemeData themeData;
  final ThemeMode themeMode;
  final ThemeType themeEventType;

  const ThemeState(
      {required this.themeData, required this.themeMode, required this.themeEventType});

  @override
  List<Object?> get props => [themeData, themeMode, themeEventType];
}

class DarkThemeState extends ThemeState {
  const DarkThemeState(
      {required super.themeData, required super.themeMode, required super.themeEventType});

  static ThemeState get darkTheme => ThemeState(
        themeData: ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(),
        ),
        themeMode: ThemeMode.dark,
        themeEventType: ThemeType.darkMode,
      );
}

class LightThemeState extends ThemeState {
  const LightThemeState({
    required super.themeData,
    required super.themeMode,
    required super.themeEventType,
  });

  static ThemeState get lightTheme => ThemeState(
      themeData: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.light(),
      ),
      themeMode: ThemeMode.light,
      themeEventType: ThemeType.lightMode);
}

class SystemThemeState extends ThemeState {
  const SystemThemeState(
      {required super.themeData, required super.themeMode, required super.themeEventType});

  static ThemeState get systemTheme => ThemeState(
      themeData: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.light(),
      ),
      themeMode: ThemeMode.system,
      themeEventType: ThemeType.system);
}
