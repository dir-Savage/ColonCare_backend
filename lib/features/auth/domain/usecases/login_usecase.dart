import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return await repository.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}