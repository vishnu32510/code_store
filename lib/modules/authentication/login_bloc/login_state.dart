part of 'login_bloc.dart';

enum FormzSubmissionStatus {initial, failure, success, inProgress}

final class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.username = "",
    this.password = "",
    this.isValid = true,
  });

  final FormzSubmissionStatus status;
  final String username;
  final String password;
  final bool isValid;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    String? username,
    String? password,
    bool? isValid,
  }) {
    return LoginState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [status, username, password];
}