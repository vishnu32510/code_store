part of 'theme_bloc.dart';

@immutable
class ThemeState {
  final ThemeData themeData;
  final ThemeMode themeMode;

  const ThemeState(this.themeData, this.themeMode);

  static ThemeState get darkTheme => ThemeState(ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.dark(),
      ),ThemeMode.dark);

  static ThemeState get lightTheme => ThemeState(ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.light(),
      ),ThemeMode.light);

      static ThemeState get systemTheme => ThemeState(ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.light(),
      ),ThemeMode.system);
}
