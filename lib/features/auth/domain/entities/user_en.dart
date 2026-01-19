import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String avatarUrl = 'https://api.dicebear.com/9.x/adventurer-neutral/svg?seed=Avery';
  final String email;
  final String fullName;
  final String? doctorPhoneNumber;  // NEW FIELD

  const User({
    required this.uid,
    required this.email,
    required this.fullName,
    this.doctorPhoneNumber,
  });

  @override
  List<Object> get props => [uid, email, fullName, doctorPhoneNumber ?? ''];

  // Factory constructor for empty user
  factory User.empty() => const User(
    uid: '',
    email: '',
    fullName: '',
    doctorPhoneNumber: null,
  );

  bool get isEmpty => uid.isEmpty && email.isEmpty && fullName.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // Copy with method
  User copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? doctorPhoneNumber,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      doctorPhoneNumber: doctorPhoneNumber ?? this.doctorPhoneNumber,
    );
  }
}