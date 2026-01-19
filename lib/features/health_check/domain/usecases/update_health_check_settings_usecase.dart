import 'package:coloncare/features/health_check/domain/entities/health_check_settings.dart';
import 'package:coloncare/features/health_check/domain/repositories/health_check_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

class UpdateHealthCheckSettingsUseCase {
  final HealthCheckRepository repository;

  UpdateHealthCheckSettingsUseCase(this.repository);

  Future<Either<Failure, Unit>> call(HealthCheckSettings settings) {
    return repository.updateHealthCheckSettings(settings);
  }
}