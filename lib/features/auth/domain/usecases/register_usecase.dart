import 'package:coloncare/features/auth/domain/entities/user_en.dart';

import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await repository.registerWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}