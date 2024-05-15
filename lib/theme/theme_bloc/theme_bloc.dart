import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.lightTheme) {
    on<ThemeEventChange>((event, emit) {
      switch (event.currentTheme) {
        case ThemeEventType.darkMode:
          emit(ThemeState.darkTheme);
          break;
        case ThemeEventType.lightMode:
          emit(ThemeState.lightTheme);
          break;
        case ThemeEventType.system:
          emit(ThemeState.systemTheme);
          break;
      }
    });
  }
}
