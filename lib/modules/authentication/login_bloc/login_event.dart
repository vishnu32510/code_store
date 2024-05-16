part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

final class LoginUsernameChanged extends LoginEvent {
  const LoginUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

final class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class FirebaseLoginWithCredentials extends LoginEvent {
  const FirebaseLoginWithCredentials();
}

final class FirebaseLoginWithGoogle extends LoginEvent {
  const FirebaseLoginWithGoogle();
}

final class CredentialLoginSubmitted extends LoginEvent {
  const CredentialLoginSubmitted();
}