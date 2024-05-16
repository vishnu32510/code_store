import 'package:code_store/firebase_options.dart';
import 'package:code_store/modules/firebase_authentication/app_bloc/app_bloc.dart';
import 'package:code_store/modules/firebase_authentication/authentication_repository.dart';
import 'package:code_store/modules/firebase_authentication/login_bloc/login_bloc.dart';
import 'package:code_store/modules/firebase_authentication/user_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationWrapper extends StatefulWidget {
  final Widget child;
  final bool firebase;
  const AuthenticationWrapper({super.key, required this.child, this.firebase = false});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  late final AuthenticationRepository _authenticationRepository;
  late final UserRepository _userRepository;
  late bool _isFirebase;

  @override
  void initState() {
    super.initState();
    _isFirebase = widget.firebase;
    _authenticationRepository =
        _isFirebase ? FirebaseAuthenticationRepository() : CredentialAuthenticationRepository();
    _userRepository = UserRepository();
  }

  Future<void> initialiseFirebase() async {
    if (_isFirebase) {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) => AppBloc(
              authenticationRepository: _authenticationRepository, userRepository: _userRepository),
        ),
        BlocProvider(
          create: (context) => LoginBloc(
            authenticationRepository: _authenticationRepository,
          ),
        ),
        // BlocProvider(
        //   create: (context) => LoginBloc(
        //     authenticationRepository: _authenticationRepository,
        //   ),
        // ),
      ], child: widget.child),
    );
  }
}
