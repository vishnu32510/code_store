part of 'theme_bloc.dart';

@immutable
abstract class ThemeEvent {}

class ThemeEventChange extends ThemeEvent {
  final ThemeType currentTheme;
  ThemeEventChange(this.currentTheme);
}
