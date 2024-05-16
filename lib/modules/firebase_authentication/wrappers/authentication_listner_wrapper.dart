import 'package:code_store/modules/firebase_authentication/app_bloc/app_bloc.dart';
import 'package:code_store/modules/firebase_authentication/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationListnerWrapper extends StatelessWidget {
  final Widget child;
  const AuthenticationListnerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          switch (state.status) {
            case AuthenticationStatus.unknown:
              debugPrint(state.status.toString());
            case AuthenticationStatus.authenticated:
              debugPrint(state.status.toString());
            case AuthenticationStatus.unauthenticated:
              debugPrint(state.status.toString());
          }
        },
        child: child);
  }
}
