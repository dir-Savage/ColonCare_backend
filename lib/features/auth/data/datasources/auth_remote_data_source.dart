// @dart=2.17
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:coloncare/features/auth/data/models/user_model.dart';
import 'package:coloncare/features/auth/domain/entities/user_en.dart';

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

  Future<void> updateUserEmail(String newEmail);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> updateUserEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      // 1. Update email in Firebase Authentication
      // await user.updateEmail(newEmail);

      // 2. Reload to make sure the local auth object is up-to-date
      await user.reload();

      // 3. Update the corresponding document in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          throw Exception(
            'This operation requires recent authentication. '
                'Please sign out and sign in again.',
          );
        case 'email-already-in-use':
          throw Exception('This email is already in use by another account.');
        case 'invalid-email':
          throw Exception('The email address is badly formatted.');
        case 'user-not-found':
          throw Exception('No user found with the given identifier.');
        default:
          throw Exception('Failed to update email: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Unexpected error while updating email: $e');
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('User creation failed – no user object returned');
    }

    final userModel = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? email.trim(),
      fullName: fullName.trim(),
      createdAt: Timestamp.now(),
      doctorPhoneNumber: null,
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(userModel.toFirestore());

    return userModel;
  }

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('Sign in failed – no user returned');
    }

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('User profile document not found');
    }

    return UserModel.fromFirestore(doc.data()!);
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc.data()!);
  }

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      return User(
        uid: data['uid'] as String,
        email: data['email'] as String,
        fullName: data['fullName'] as String,
        doctorPhoneNumber: data['doctorPhoneNumber'] as String?,
      );
    });
  }
}