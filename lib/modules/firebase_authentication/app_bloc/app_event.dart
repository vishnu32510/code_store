part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

final class FirebaseAuthentcationLogoutRequested extends AppEvent {
  const FirebaseAuthentcationLogoutRequested();
}

final class _FirebaseAuthenticationUserChanged extends AppEvent {
  const _FirebaseAuthenticationUserChanged(this.user);

  final User user;
}

//Without Firebase
final class _CredentialAuthenticationStatusChanged extends AppEvent {
  const _CredentialAuthenticationStatusChanged(this.status);

  final AuthenticationStatus status;
}

final class CredentialAuthenticationLogoutRequested extends AppEvent {}
