import 'package:coloncare/features/auth/domain/repositories/auth_repository.dart';

class UpdateEmailUseCase {
  final AuthRepository repository;

  UpdateEmailUseCase(this.repository);

  Future<void> call(String newEmail) async {
    await repository.updateEmail(newEmail);
  }
}