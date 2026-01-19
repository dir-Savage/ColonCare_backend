import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel != null) {
        final user = userModel.toEntity();
        await localDataSource.cacheUser(user);
        return user;
      }
      return await localDataSource.getCachedUser();
    } catch (e) {
      return await localDataSource.getCachedUser();
    }
  }

  @override
  Future<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final userModel = await remoteDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
    );

    final user = userModel.toEntity();
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userModel = await remoteDataSource.loginWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userModel.toEntity();
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await localDataSource.clearUserCache();
  }

  @override
  Future<void> resetPassword(String email) async {
    await remoteDataSource.resetPassword(email);
  }

  @override
  Stream<User?> authStateChanges() {
    return remoteDataSource.authStateChanges();
  }
}