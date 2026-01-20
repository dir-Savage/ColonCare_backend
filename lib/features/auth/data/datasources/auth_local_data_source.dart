// FILE: auth/data/datasources/auth_local_data_source.dart
import 'dart:convert';
import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<User?> getCachedUser();
  Future<void> clearUserCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'cached_user';

  @override
  Future<void> cacheUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode({
      'uid': user.uid,
      'email': user.email,
      'fullName': user.fullName,
      // Note: doctorPhoneNumber is now stored separately in StorageService
    });
    await prefs.setString(_userKey, userJson);
  }

  @override
  Future<User?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User(
        uid: userMap['uid'] as String,
        email: userMap['email'] as String,
        fullName: userMap['fullName'] as String,
        doctorPhoneNumber: null, // Will be fetched separately from StorageService
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUserCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}