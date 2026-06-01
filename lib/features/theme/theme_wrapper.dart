import 'package:code_store/core/di/injection.dart';
import 'package:code_store/features/theme/theme_bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeWrapper extends StatelessWidget {
  const ThemeWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) => getIt<ThemeBloc>(),
      child: child,
    );
  }
}
