import 'dart:async';
import 'package:bloc/bloc.dart';
import '/repositories/userRepository.dart';
import '/ui/validators.dart';
import 'package:meta/meta.dart';
import './bloc.dart';
import 'package:rxdart/rxdart.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  UserRepository _userRepository;

  SignUpBloc({required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository, super(SignUpState.empty()){
    on<EmailChanged>(_onEmailAdded);
    on<PasswordChanged>(_onPasswordAdded);
    on<SignUpWithCredentialsPressed>(_onSignUpWithCredentialsPressed);
  }

  void _onEmailAdded //(String email)
      (EmailChanged event, Emitter<SignUpState> emit,) {
    final email = event.email;
    emit (state.update(isEmailValid: Validators.isValidEmail(email),));
  }

  void _onPasswordAdded//(String password)
      (PasswordChanged event, Emitter<SignUpState> emit,) async {
    final password = event.password;
    emit (state.update(isEmailValid: Validators.isValidPassword(password)));
  }
  void _onSignUpWithCredentialsPressed (SignUpWithCredentialsPressed event, Emitter<SignUpState> emit,) async {
    emit (SignUpState.loading());
    final email = event.email;
    final password = event.password;
    try {
      await _userRepository.signUpWithEmail(email, password);

      emit(SignUpState.success()) ;
    } catch (_) {
      emit(SignUpState.failure()) ;
    }
  }
}
