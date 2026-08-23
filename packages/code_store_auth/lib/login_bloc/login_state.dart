part of 'login_bloc.dart';

final class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.email = '',
    this.password = '',
    this.isValid = true,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final String email;
  final String password;
  final bool isValid;
  final String? errorMessage;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    String? email,
    String? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, email, password, isValid, errorMessage];
}
