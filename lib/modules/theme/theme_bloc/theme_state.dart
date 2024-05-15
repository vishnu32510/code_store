part of 'theme_bloc.dart';

@immutable
class ThemeState extends Equatable {
  final ThemeData themeData;
  final ThemeMode themeMode;

  const ThemeState(this.themeData, this.themeMode);

  @override
  List<Object?> get props => [themeData, themeMode];
}

class DarkThemeState extends ThemeState {
  const DarkThemeState(super.themeData, super.themeMode);

  static ThemeState get darkTheme => ThemeState(
      ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.dark(),
      ),
      ThemeMode.dark);
}

class LightThemeState extends ThemeState {
  const LightThemeState(super.themeData, super.themeMode);
  
  static ThemeState get lightTheme => ThemeState(
      ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.light(),
      ),
      ThemeMode.light);
}

class SystemThemeState extends ThemeState {
  const SystemThemeState(super.themeData, super.themeMode);

  static ThemeState get systemTheme => ThemeState(
      ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.light(),
      ),
      ThemeMode.system);
}
