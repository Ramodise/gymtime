import 'dart:async';
import 'package:bloc/bloc.dart';
import '/repositories/userRepository.dart';
import 'package:flutter/cupertino.dart';
import './bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(Uninitialized()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(
      AppStarted event,
      Emitter<AuthenticationState> emit,
      ) async {
    try {
      final isSignedIn = await _userRepository.isSignedIn();
      if (isSignedIn) {
        final uid = await _userRepository.getUser();
        final isFirstTime = await _userRepository.isFirstTime(uid);
        if (!isFirstTime) {
          emit(AuthenticatedButNotSet(uid));
        } else {
          emit(Authenticated(uid));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoggedIn(
      LoggedIn event,
      Emitter<AuthenticationState> emit,
      ) async {
    final isFirstTime = await _userRepository.isFirstTime(await _userRepository.getUser());
    if (!isFirstTime) {
      emit(AuthenticatedButNotSet(await _userRepository.getUser()));
    } else {
      emit(Authenticated(await _userRepository.getUser()));
    }
  }

  void _onLoggedOut(
      LoggedOut event,
      Emitter<AuthenticationState> emit,
      ) {
    //Unauthenticated();
    _userRepository.signOut();
    emit(Unauthenticated());
  }
}
