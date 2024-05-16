import 'package:bloc/bloc.dart';
import 'package:code_store/modules/authentication/authentication_enums.dart';
import 'package:code_store/modules/authentication/authentication_repository.dart';
import 'package:equatable/equatable.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<FirebaseLoginWithCredentials>(_loginWithCredentials);
    on<FirebaseLoginWithGoogle>(_logInWithGoogle);
    on<CredentialLoginSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    final username = event.username;
    emit(
      state.copyWith(
        username: username,
        isValid: true,
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = event.password;
    emit(
      state.copyWith(
        password: password,
        isValid: true,
      ),
    );
  }

  Future<void> _loginWithCredentials(
    FirebaseLoginWithCredentials event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await (_authenticationRepository as FirebaseAuthenticationRepository).logInWithEmailAndPassword(
        email: state.username,
        password: state.password,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> _logInWithGoogle(
      FirebaseLoginWithGoogle event, 
      Emitter<LoginState> emit
      ) async {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await (_authenticationRepository as FirebaseAuthenticationRepository).logInWithGoogle();
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } on LogInWithGoogleFailure catch (e) {
        emit(
          state.copyWith(
            errorMessage: e.message,
            status: FormzSubmissionStatus.failure,
          ),
        );
      } catch (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }

    Future<void> _onSubmitted(
    CredentialLoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await (_authenticationRepository as CredentialAuthenticationRepository).logIn(
          username: state.username,
          password: state.password,
        );
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }
  }
}
