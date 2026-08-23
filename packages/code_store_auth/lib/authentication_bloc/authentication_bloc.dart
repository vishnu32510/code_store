import 'dart:async';

import 'package:bloc/bloc.dart';

import '../authentication_enums.dart';
import '../authentication_repository.dart';
import '../user.dart';

import 'package:equatable/equatable.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationBlocState> {
  AuthenticationBloc({required this._authenticationRepository})
    : super(const AuthenticationBlocState.unknown()) {
    on<_UserChanged>(_onUserChanged);
    on<LogoutRequested>(_onLogoutRequested);
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_UserChanged(user)),
    );
  }

  final FirebaseAuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;

  void _onUserChanged(
    _UserChanged event,
    Emitter<AuthenticationBlocState> emit,
  ) {
    emit(
      event.user.isNotEmpty
          ? AuthenticationBlocState.authenticated(event.user)
          : const AuthenticationBlocState.unauthenticated(),
    );
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthenticationBlocState> emit,
  ) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
