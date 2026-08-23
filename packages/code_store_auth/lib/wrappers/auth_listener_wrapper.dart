import '../authentication_bloc/authentication_bloc.dart';
import '../authentication_enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Listens for auth state changes and notifies callbacks.
class AuthenticationListenerWrapper extends StatelessWidget {
  const AuthenticationListenerWrapper({
    super.key,
    required this.child,
    this.onAuthenticated,
    this.onUnauthenticated,
    this.onAuthStateChanged,
  });

  final Widget child;
  final VoidCallback? onAuthenticated;
  final VoidCallback? onUnauthenticated;
  final ValueChanged<AuthenticationBlocState>? onAuthStateChanged;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationBlocState>(
      listener: (context, state) {
        if (kDebugMode) {
          debugPrint('AuthenticationBloc: ${state.status}');
        }

        onAuthStateChanged?.call(state);
        if (state.status == AuthenticationStatus.unknown) return;

        final signedIn =
            state.status == AuthenticationStatus.authenticated &&
            state.user.isNotEmpty;

        if (signedIn) {
          onAuthenticated?.call();
        } else if (state.status == AuthenticationStatus.unauthenticated) {
          onUnauthenticated?.call();
        }
      },
      child: child,
    );
  }
}
