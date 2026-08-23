part of 'theme_bloc.dart';

@immutable
class ThemeState extends Equatable {
  final AppThemeConfig currentTheme;
  final List<AppThemeConfig> availableThemes;

  const ThemeState({
    required this.currentTheme,
    required this.availableThemes,
  });

  ThemeData get themeData => currentTheme.themeData;
  ThemeMode get themeMode => currentTheme.themeMode;
  String get currentThemeId => currentTheme.id;

  AppThemeConfig get nextTheme {
    if (availableThemes.isEmpty) return currentTheme;
    final currentIndex = availableThemes.indexWhere((t) => t.id == currentTheme.id);
    if (currentIndex == -1 || currentIndex == availableThemes.length - 1) {
      return availableThemes.first;
    }
    return availableThemes[currentIndex + 1];
  }

  ThemeState copyWith({
    AppThemeConfig? currentTheme,
    List<AppThemeConfig>? availableThemes,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      availableThemes: availableThemes ?? this.availableThemes,
    );
  }

  @override
  List<Object?> get props => [currentTheme, availableThemes];
}

class DarkThemeState {
  static ThemeData get darkThemeData => AppThemeConfig.dark.themeData;
}

class LightThemeState {
  static ThemeData get lightThemeData => AppThemeConfig.light.themeData;
}
