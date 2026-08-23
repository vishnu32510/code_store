import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../models/app_theme_config.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({
    List<AppThemeConfig>? availableThemes,
    String? initialThemeId,
  }) : super(_createInitialState(availableThemes, initialThemeId)) {
    on<ThemeEventChange>((event, emit) {
      emit(state.copyWith(currentTheme: event.theme));
    });

    on<ThemeEventChangeById>((event, emit) {
      final matched = state.availableThemes.firstWhere(
        (t) => t.id == event.themeId,
        orElse: () => state.currentTheme,
      );
      emit(state.copyWith(currentTheme: matched));
    });

    on<ThemeEventCycleNext>((event, emit) {
      emit(state.copyWith(currentTheme: state.nextTheme));
    });

    on<ThemeEventSetThemes>((event, emit) {
      final newThemes = event.availableThemes.isNotEmpty
          ? event.availableThemes
          : AppThemeConfig.defaultThemes;

      AppThemeConfig active = newThemes.first;
      if (event.activeThemeId != null) {
        active = newThemes.firstWhere(
          (t) => t.id == event.activeThemeId,
          orElse: () => newThemes.first,
        );
      } else {
        active = newThemes.firstWhere(
          (t) => t.id == state.currentTheme.id,
          orElse: () => newThemes.first,
        );
      }

      emit(ThemeState(
        currentTheme: active,
        availableThemes: newThemes,
      ));
    });
  }

  static ThemeState _createInitialState(
    List<AppThemeConfig>? customThemes,
    String? initialThemeId,
  ) {
    final themes = (customThemes != null && customThemes.isNotEmpty)
        ? customThemes
        : AppThemeConfig.defaultThemes;

    final initial = (initialThemeId != null)
        ? themes.firstWhere((t) => t.id == initialThemeId, orElse: () => themes.first)
        : themes.first;

    return ThemeState(
      currentTheme: initial,
      availableThemes: themes,
    );
  }
}
