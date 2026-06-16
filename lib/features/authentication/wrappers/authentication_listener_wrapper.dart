import '../authentication_bloc/authentication_bloc.dart';
import '../authentication_enums.dart';
import '../../../../core/config/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Listens for auth state changes and navigates the user appropriately.
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
        
        final signedIn =
            state.status == AuthenticationStatus.authenticated &&
            state.user.isNotEmpty;
        
        // Use the root navigator for auth redirects
        if (signedIn) {
          context.go(AppRoutes.dashboard);
        } else {
          context.go(AppRoutes.login);
        }
      },
      child: child,
    );
  }
}
