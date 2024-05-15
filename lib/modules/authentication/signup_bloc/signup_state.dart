part of 'signup_bloc.dart';

enum FormzSubmissionStatus {initial, failure, success, inProgress}

final class SignupState extends Equatable {
  const SignupState({
    this.status = FormzSubmissionStatus.initial,
    this.username = "",
    this.email = "",
    this.password = "",
    this.isValid = true,
  });

  final FormzSubmissionStatus status;
  final String username;
  final String password;
  final String email;
  final bool isValid;

  SignupState copyWith({
    FormzSubmissionStatus? status,
    String? username,
    String? password,
    String? email,
    bool? isValid,
  }) {
    return SignupState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [status, username, password];
}