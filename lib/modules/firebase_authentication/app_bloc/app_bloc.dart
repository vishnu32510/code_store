import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:code_store/modules/firebase_authentication/authentication_repository.dart';
import 'package:code_store/modules/firebase_authentication/user.dart';
import 'package:code_store/modules/firebase_authentication/user_repository.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository,
  required UserRepository userRepository,})
      : _authenticationRepository = authenticationRepository,
      _userRepository = userRepository,
        super(const AppState.unknown()
          // authenticationRepository.currentUser.isNotEmpty
          //     ? AppState.authenticated(authenticationRepository.currentUser)
          //     : const AppState.unauthenticated(),
        ) {
    on<_FirebaseAuthenticationUserChanged>(_onUserChanged);
    on<FirebaseAuthentcationLogoutRequested>(_onLogoutRequested);
    on<_CredentialAuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<CredentialAuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
    if(_authenticationRepository is FirebaseAuthenticationRepository){
      _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_FirebaseAuthenticationUserChanged(user)),
    );}
    if(_authenticationRepository is CredentialAuthenticationRepository){
      _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) => add(_CredentialAuthenticationStatusChanged(status)),
    );
    }
  }

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  late final StreamSubscription<User> _userSubscription;
  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  void _onUserChanged(_FirebaseAuthenticationUserChanged event, Emitter<AppState> emit) {
    emit(
      event.user.isNotEmpty
          ? AppState.authenticated(event.user)
          : const AppState.unauthenticated(),
    );
  }

  void _onLogoutRequested(FirebaseAuthentcationLogoutRequested event, Emitter<AppState> emit) {
    unawaited((_authenticationRepository as FirebaseAuthenticationRepository).logOut());
  }

   Future<void> _onAuthenticationStatusChanged(
    _CredentialAuthenticationStatusChanged event,
    Emitter<AppState> emit,
  ) async {
    switch (event.status) {
      case AuthenticationStatus.unauthenticated:
        return emit(const AppState.unauthenticated());
      case AuthenticationStatus.authenticated:
        final user = await _tryGetUser();
        return emit(
          user != null
              ? AppState.authenticated(user)
              : const AppState.unauthenticated(),
        );
      case AuthenticationStatus.unknown:
        return emit(const AppState.unknown());
    }
  }

  void _onAuthenticationLogoutRequested(
    CredentialAuthenticationLogoutRequested event,
    Emitter<AppState> emit,
  ) {
    (_authenticationRepository as CredentialAuthenticationRepository).logOut();
  }

  Future<User?> _tryGetUser() async {
    try {
      final user = await _userRepository.getUser();
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    _authenticationStatusSubscription.cancel();
    return super.close();
  }
}
