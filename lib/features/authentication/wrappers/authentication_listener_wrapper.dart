import 'package:code_store/features/authentication/authentication_bloc/authentication_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Optional: log auth transitions while building features on top of the template.
class AuthenticationListenerWrapper extends StatelessWidget {
  const AuthenticationListenerWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationBlocState>(
      listener: (context, state) {
        if (kDebugMode) {
          debugPrint('AuthenticationBloc: ${state.status}');
        }
      },
      child: child,
    );
  }
}
