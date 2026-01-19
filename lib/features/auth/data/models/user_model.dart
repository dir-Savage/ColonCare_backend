import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String fullName;
  final Timestamp? createdAt;
  final String? doctorPhoneNumber;  // NEW FIELD

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.createdAt,
    this.doctorPhoneNumber,
  });

  User toEntity() => User(
    uid: uid,
    email: email,
    fullName: fullName,
    doctorPhoneNumber: doctorPhoneNumber,
  );

  factory UserModel.fromEntity(User user) => UserModel(
    uid: user.uid,
    email: user.email,
    fullName: user.fullName,
    doctorPhoneNumber: user.doctorPhoneNumber,
  );

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'doctorPhoneNumber': doctorPhoneNumber,  // NEW FIELD
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      fullName: data['fullName'] as String,
      createdAt: data['createdAt'] as Timestamp?,
      doctorPhoneNumber: data['doctorPhoneNumber'] as String?,
    );
  }

  @override
  List<Object?> get props => [uid, email, fullName, createdAt, doctorPhoneNumber];
}