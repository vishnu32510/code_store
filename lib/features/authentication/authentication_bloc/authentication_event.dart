part of 'authentication_bloc.dart';

sealed class AuthenticationEvent {
  const AuthenticationEvent();
}

final class _UserChanged extends AuthenticationEvent {
  const _UserChanged(this.user);
  final User user;
}

final class LogoutRequested extends AuthenticationEvent {
  const LogoutRequested();
}
