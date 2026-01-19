import 'package:coloncare/features/health_check/domain/entities/health_check_result.dart';
import 'package:coloncare/features/health_check/domain/repositories/health_check_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

class SaveHealthCheckResultUseCase {
  final HealthCheckRepository repository;

  SaveHealthCheckResultUseCase(this.repository);

  Future<Either<Failure, Unit>> call(HealthCheckResult result) {
    return repository.saveHealthCheckResult(result);
  }
}