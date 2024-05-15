import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(LightThemeState.lightTheme) {
    on<ThemeEventChange>((event, emit) {
      switch (event.currentTheme) {
        case ThemeEventType.darkMode:
          emit(DarkThemeState.darkTheme);
          break;
        case ThemeEventType.lightMode:
          emit(LightThemeState.lightTheme);
          break;
        case ThemeEventType.system:
          emit(SystemThemeState.systemTheme);
          break;
      }
    });
  }
}
