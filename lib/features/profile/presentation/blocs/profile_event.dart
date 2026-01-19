part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}




class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateDoctorPhoneRequested extends ProfileEvent {
  final String phoneNumber;

  const ProfileUpdateDoctorPhoneRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? fullName;
  final String? email;
  final String? doctorPhoneNumber;

  const ProfileUpdateRequested({
    this.fullName,
    this.email,
    this.doctorPhoneNumber,
  });

  @override
  List<Object> get props => [
    fullName ?? '',
    email ?? '',
    doctorPhoneNumber ?? '',
  ];
}