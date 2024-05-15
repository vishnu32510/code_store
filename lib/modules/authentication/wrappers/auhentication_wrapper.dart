import 'package:code_store/modules/authentication/authentication_bloc/authentication_bloc.dart';
import 'package:code_store/modules/authentication/authentication_repository.dart';
import 'package:code_store/modules/authentication/login_bloc/login_bloc.dart';
import 'package:code_store/modules/authentication/signup_bloc/signup_bloc.dart';
import 'package:code_store/modules/authentication/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;
  const AuthenticationWrapper({super.key, required this.child, this.navigatorKey});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  // ignore: unused_field
  late final GlobalKey<NavigatorState> _navigatorKey;
  late final AuthenticationRepository _authenticationRepository;
  late final UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _authenticationRepository = AuthenticationRepository();
    _userRepository = UserRepository();
    _navigatorKey = widget.navigatorKey ?? GlobalKey<NavigatorState>();
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthenticationBloc(
                authenticationRepository: _authenticationRepository,
                userRepository: _userRepository),
          ),
          BlocProvider(
            create: (context) => SignupBloc(
              authenticationRepository: _authenticationRepository,
            ),
          ),
          BlocProvider(
            create: (context) => LoginBloc(
              authenticationRepository: _authenticationRepository,
            ),
          ),
        ],
        child: widget.child,
      ),
    );
  }
}
