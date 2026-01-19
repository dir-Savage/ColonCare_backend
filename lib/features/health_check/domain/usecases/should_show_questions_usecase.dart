import 'package:coloncare/features/health_check/data/repositories/health_check_repository_impl.dart';
import 'package:coloncare/features/health_check/domain/repositories/health_check_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

class ShouldShowQuestionsUseCase {
  final HealthCheckRepository repository;

  ShouldShowQuestionsUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    try {
      final shouldShow = await repository.shouldShowQuestions();
      return Right(shouldShow);
    } catch (e) {
      return Left(HealthCheckFailure('Failed to check if questions should be shown: $e'));
    }
  }
}