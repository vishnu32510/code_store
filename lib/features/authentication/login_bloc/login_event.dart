part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

final class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);
  final String email;

  @override
  List<Object> get props => [email];
}

final class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);
  final String password;

  @override
  List<Object> get props => [password];
}

final class LoginWithEmailAndPassword extends LoginEvent {
  const LoginWithEmailAndPassword({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

final class SignUpWithEmailAndPassword extends LoginEvent {
  const SignUpWithEmailAndPassword({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

final class ContinueWithEmailAndPassword extends LoginEvent {
  const ContinueWithEmailAndPassword({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

final class LoginWithGoogle extends LoginEvent {
  const LoginWithGoogle();
}

final class LoginWithApple extends LoginEvent {
  const LoginWithApple();
}
