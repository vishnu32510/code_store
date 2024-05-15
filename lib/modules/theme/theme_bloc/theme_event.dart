part of 'theme_bloc.dart';

@immutable
abstract class ThemeEvent {}

class ThemeEventChange extends ThemeEvent {
  final ThemeEventType currentTheme;
  ThemeEventChange(this.currentTheme);
}

enum ThemeEventType {
  darkMode, // Event for toggling to dark theme
  lightMode, // Event for toggling to light theme
  system, // Event for toggling to light theme
}
