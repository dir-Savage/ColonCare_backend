import 'package:coloncare/features/auth/domain/entities/user_en.dart';

abstract class AuthRepository {
  // Get current authenticated user
  Future<User?> getCurrentUser();

  // Register with email and password
  Future<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  // Login with email and password
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Logout
  Future<void> logout();

  // Reset password
  Future<void> resetPassword(String email);

  // Listen to auth state changes
  Stream<User?> authStateChanges();
}