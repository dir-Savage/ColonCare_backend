import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coloncare/core/utils/doctor_phone_helper.dart';
import 'package:coloncare/features/auth/data/models/user_model.dart';
import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_bloc/flutter_bloc.dart';

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
      // Load doctor phone from storage
      final userWithPhone = await User.withDoctorPhone(userModel.toEntity());
      emit(ProfileLoaded(user: userWithPhone));
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
      final phoneNumber = event.phoneNumber.trim();

      // Validate phone number
      if (!_isValidPhone(phoneNumber)) {
        emit(ProfileError('Invalid phone number format', user: currentState.user));
        return;
      }

      // Save to local storage
      await StorageService.saveDoctorPhone(phoneNumber);

      // Optional: Save to Firestore as well
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'doctorPhoneNumber': phoneNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final updatedUser = currentState.user!.copyWith(
        doctorPhoneNumber: phoneNumber,
      );

      emit(ProfileLoaded(user: updatedUser));
      emit(ProfileUpdateSuccess(
        user: updatedUser,
        message: 'Doctor phone number updated successfully',
      ));
    } catch (e) {
      emit(ProfileError('Failed to update phone number: $e', user: currentState.user));
    }
  }

  bool _isValidPhone(String phone) {
    // Basic phone validation
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d+]'), ''));
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

      if (event.doctorPhoneNumber != null && event.doctorPhoneNumber!.trim().isNotEmpty) {
        final phoneNumber = event.doctorPhoneNumber!.trim();

        if (!_isValidPhone(phoneNumber)) {
          emit(ProfileError('Invalid phone number format', user: currentState.user));
          return;
        }

        // Save to local storage
        await StorageService.saveDoctorPhone(phoneNumber);

        updates['doctorPhoneNumber'] = phoneNumber;
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }

      final updatedUser = currentState.user!.copyWith(
        fullName: event.fullName?.trim() ?? currentState.user!.fullName,
        doctorPhoneNumber: event.doctorPhoneNumber?.trim() ?? currentState.user!.doctorPhoneNumber,
      );

      emit(ProfileLoaded(user: updatedUser));
      emit(ProfileUpdateSuccess(
        user: updatedUser,
        message: 'Profile updated successfully',
      ));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e', user: currentState.user));
    }
  }
}