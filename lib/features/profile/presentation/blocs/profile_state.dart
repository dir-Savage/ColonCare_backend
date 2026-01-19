part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  final User? user;

  const ProfileState({this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required User super.user});

  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating({required User super.user});

  @override
  List<Object?> get props => [user];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess({
    required User super.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

class ProfileError extends ProfileState {
  final String error;

  const ProfileError(
      this.error, {
        User? user,
      }) : super(user: user);

  @override
  List<Object?> get props => [error, user];
}