import '../../../../core/config/routes.dart';
import '../authentication_bloc/authentication_bloc.dart';
import '../authentication_enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Listens for auth state changes and navigates the user appropriately.
///
/// Uses [AppRouter.router.go] instead of [BuildContext.go] so this wrapper is
/// safe to place above the GoRouter subtree (e.g. in [MaterialApp.router]'s
/// `builder`).
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

        if (state.status == AuthenticationStatus.unknown) return;

        final signedIn =
            state.status == AuthenticationStatus.authenticated &&
            state.user.isNotEmpty;

        final location = signedIn ? AppRoutes.dashboard : AppRoutes.login;
        AppRouter.router.go(location);
      },
      child: child,
    );
  }
}
