import 'package:bloc/bloc.dart';
import '../authentication_enums.dart';
import '../authentication_repository.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required FirebaseAuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository,
       super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginWithEmailAndPassword>(_onLoginWithEmail);
    on<SignUpWithEmailAndPassword>(_onSignUpWithEmail);
    on<ContinueWithEmailAndPassword>(_onContinueWithEmail);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithApple>(_onLoginWithApple);
  }

  final FirebaseAuthenticationRepository _authenticationRepository;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, isValid: true));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, isValid: true));
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailAndPassword event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: event.email,
        password: event.password,
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

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailAndPassword event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on SignUpWithEmailAndPasswordFailure catch (e) {
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

  Future<void> _onContinueWithEmail(
    ContinueWithEmailAndPassword event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          await _authenticationRepository.logInWithEmailAndPassword(
            email: event.email,
            password: event.password,
          );
          emit(state.copyWith(status: FormzSubmissionStatus.success));
        } on LogInWithEmailAndPasswordFailure catch (loginError) {
          emit(
            state.copyWith(
              errorMessage: loginError.message,
              status: FormzSubmissionStatus.failure,
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            errorMessage: e.message,
            status: FormzSubmissionStatus.failure,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithGoogleCancelled {
      emit(state.copyWith(status: FormzSubmissionStatus.initial));
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

  Future<void> _onLoginWithApple(
    LoginWithApple event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithApple();
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
}
