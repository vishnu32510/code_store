part of 'theme_bloc.dart';

@immutable
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeEventChange extends ThemeEvent {
  final AppThemeConfig theme;
  const ThemeEventChange(this.theme);

  @override
  List<Object?> get props => [theme];
}

class ThemeEventChangeById extends ThemeEvent {
  final String themeId;
  const ThemeEventChangeById(this.themeId);

  @override
  List<Object?> get props => [themeId];
}

class ThemeEventCycleNext extends ThemeEvent {
  const ThemeEventCycleNext();
}

class ThemeEventSetThemes extends ThemeEvent {
  final List<AppThemeConfig> availableThemes;
  final String? activeThemeId;

  const ThemeEventSetThemes(this.availableThemes, {this.activeThemeId});

  @override
  List<Object?> get props => [availableThemes, activeThemeId];
}
