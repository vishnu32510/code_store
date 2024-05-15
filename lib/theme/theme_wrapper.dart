import 'package:code_store/theme/theme_bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeWrapper extends StatelessWidget {
  final Widget child;
  const ThemeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: child,
    );
  }
}
