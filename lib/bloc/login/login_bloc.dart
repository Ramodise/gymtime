import 'dart:async';
import 'package:bloc/bloc.dart';
import '/repositories/userRepository.dart';
import '/ui/validators.dart';
import 'package:meta/meta.dart';
import './bloc.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserRepository _userRepository;

  LoginBloc({required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository, super(LoginState.empty()){
    on<EmailChanged>(_onEmailAdded);
    on<PasswordChanged>(_onPasswordAdded);
    on<LoginWithCredentialsPressed>(_onLoginWithCredentialsPressed);
  }

  void _onEmailAdded (EmailChanged event, Emitter<LoginState> emit,) {
    final email = event.email;
    emit(state.update(isEmailValid: Validators.isValidEmail(email)));
  }
  void _onPasswordAdded (PasswordChanged event, Emitter<LoginState> emit,) {
    final password = event.password;
    emit(state.update(isEmailValid: Validators.isValidPassword(password)));
  }
  void _onLoginWithCredentialsPressed (LoginWithCredentialsPressed event, Emitter<LoginState> emit,) async {
    emit(LoginState.loading());
    final email = event.email;
    final password = event.password;
    try {
      await _userRepository.signInWithEmail(email, password);
      emit(LoginState.success()) ;
    } catch (_) {
      LoginState.failure();
    };
  }
}
