import '../authentication/authentication_bloc/authentication_bloc.dart';
import '../authentication/authentication_enums.dart';
import '../authentication/screens/login_screen.dart';
import 'dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationBlocState>(
      builder: (context, auth) {
        final signedIn =
            auth.status == AuthenticationStatus.authenticated &&
            auth.user.isNotEmpty;

        if (signedIn) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
