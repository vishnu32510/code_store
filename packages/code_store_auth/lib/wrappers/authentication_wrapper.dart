import '../authentication_bloc/authentication_bloc.dart';
import '../authentication_repository.dart';
import '../login_bloc/login_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  late final FirebaseAuthenticationRepository _authenticationRepository;

  @override
  void initState() {
    super.initState();
    _authenticationRepository = FirebaseAuthenticationRepository();
    // google_sign_in v7: initialize() must be called exactly once before sign-in.
    _authenticationRepository.initializeGoogleSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthenticationBloc(
              authenticationRepository: _authenticationRepository,
            ),
          ),
          BlocProvider(
            create: (_) =>
                LoginBloc(authenticationRepository: _authenticationRepository),
          ),
        ],
        child: widget.child,
      ),
    );
  }
}
