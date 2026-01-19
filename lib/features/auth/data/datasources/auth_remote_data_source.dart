
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore, FieldValue, Timestamp;
import 'package:coloncare/features/auth/data/models/user_model.dart';
import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

abstract class AuthRemoteDataSource {
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<UserModel?> getCurrentUser();
  Stream<User?> authStateChanges();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('User creation failed');
      }

      // 2. Create user in Firestore
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        fullName: fullName.trim(),
        createdAt: Timestamp.now(),
        doctorPhoneNumber: null,  // Default to null
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toFirestore());

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed');
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      final data = userDoc.data()!;
      return UserModel(
        uid: data['uid'] as String,
        email: data['email'] as String,
        fullName: data['fullName'] as String,
        createdAt: data['createdAt'] as Timestamp?,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromFirestore(userDoc.data()!);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          return null;
        }

        final data = userDoc.data()!;
        return User(
          uid: data['uid'] as String,
          email: data['email'] as String,
          fullName: data['fullName'] as String,
          doctorPhoneNumber: data['doctorPhoneNumber'] as String?,
        );
      } catch (e) {
        return null;
      }
    });
  }
}