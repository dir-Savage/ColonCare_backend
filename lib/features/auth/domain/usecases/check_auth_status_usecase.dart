import 'package:coloncare/features/auth/domain/entities/user_en.dart';

import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}