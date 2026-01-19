import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coloncare/core/failures/failure.dart';
import 'package:coloncare/features/auth/data/models/user_model.dart';
import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileBloc({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateDoctorPhoneRequested>(_onProfileUpdateDoctorPhoneRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onProfileLoadRequested(
      ProfileLoadRequested event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const ProfileError('User not authenticated'));
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        emit(const ProfileError('User data not found'));
        return;
      }

      final userModel = UserModel.fromFirestore(userDoc.data()!);
      emit(ProfileLoaded(user: userModel.toEntity()));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onProfileUpdateDoctorPhoneRequested(
      ProfileUpdateDoctorPhoneRequested event,
      Emitter<ProfileState> emit,
      ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating(user: currentState.user!));

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(ProfileError('User not authenticated', user: currentState.user));
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'doctorPhoneNumber': event.phoneNumber.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedUser = currentState.user?.copyWith(
        doctorPhoneNumber: event.phoneNumber.trim(),
      );

      emit(ProfileLoaded(user: updatedUser!));
      emit(ProfileUpdateSuccess(
        user: updatedUser,
        message: 'Doctor phone number updated successfully',
      ));
    } catch (e) {
      emit(ProfileError('Failed to update phone number: $e', user: currentState.user));
    }
  }

  Future<void> _onProfileUpdateRequested(
      ProfileUpdateRequested event,
      Emitter<ProfileState> emit,
      ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating(user: currentState.user!));

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(ProfileError('User not authenticated', user: currentState.user));
        return;
      }

      final updates = <String, dynamic>{};

      if (event.fullName != null && event.fullName!.trim().isNotEmpty) {
        updates['fullName'] = event.fullName!.trim();
      }

      if (event.email != null && event.email!.trim().isNotEmpty) {
        updates['email'] = event.email!.trim();
        // Note: You might need to update email in Firebase Auth separately
      }

      if (event.doctorPhoneNumber != null) {
        updates['doctorPhoneNumber'] = event.doctorPhoneNumber!.trim();
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).update(updates);

      final updatedUser = currentState.user?.copyWith(
        fullName: event.fullName?.trim() ?? currentState.user?.fullName,
        email: event.email?.trim() ?? currentState.user?.email,
        doctorPhoneNumber: event.doctorPhoneNumber?.trim() ?? currentState.user?.doctorPhoneNumber,
      );

      emit(ProfileLoaded(user: updatedUser!));
      emit(ProfileUpdateSuccess(
        user: updatedUser,
        message: 'Profile updated successfully',
      ));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e', user: currentState.user));
    }
  }
}