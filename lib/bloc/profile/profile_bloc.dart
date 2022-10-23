import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import '/repositories/userRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import './bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  UserRepository _userRepository;

  ProfileBloc({required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(ProfileState.empty()) {
    on<NameChanged>(_onNameChanged);
    on<AgeChanged>(_onAgeChanged);
    on<GenderChanged>(_onGenderChanged);
    on<PhotoChanged>(_onPhotoChanged);
    on<Submitted>(_onSubmitted);
  }

  void _onNameChanged(
      NameChanged event,
      Emitter<ProfileState> emit,
      ) {
    final name = event.name;
    emit(state.update(
      isNameEmpty: name == null,
    ));
  }

  void _onAgeChanged(
      AgeChanged event,
      Emitter<ProfileState> emit,
      ) {
    final age = event.age;
    emit(state.update(
      isAgeEmpty: age == null,
    ));
  }

  void _onGenderChanged(
      GenderChanged event,
      Emitter<ProfileState> emit,
      ) {
    final gender = event.gender;
    emit(state.update(
      isGenderEmpty: gender == null,
    ));
  }

  void _onPhotoChanged(
      PhotoChanged event,
      Emitter<ProfileState> emit,
      ) {
    final photo = event.photo;
    emit(state.update(
      isPhotoEmpty: photo == null,
    ));
  }

  void _onSubmitted(
      Submitted event,
      Emitter<ProfileState> emit,
      ) async {
    final userId = await _userRepository.getUser();
    final photo = event.photo;
    final name = event.name;
    final age = event.age;
    final gender = event.gender;

    emit(ProfileState.loading());
    try {
      await _userRepository.profileSetup(
        photo,
        userId,
        name,
        age,
        gender,
        // interestedIn,
        //location,
      );
      emit(ProfileState.success());
    } catch (_) {
      emit(ProfileState.failure());
    }
  }
}
