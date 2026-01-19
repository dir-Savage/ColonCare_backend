import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_result.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_settings.dart';

abstract class HealthCheckRepository {
  /// Check if health questions should be shown
  Future<bool> shouldShowQuestions();

  /// Get time remaining until next check
  Future<Duration> getTimeUntilNextCheck();

  /// Save health check results
  Future<Either<Failure, Unit>> saveHealthCheckResult(HealthCheckResult result);

  /// Get health check history
  Future<Either<Failure, List<HealthCheckResult>>> getHealthCheckHistory();

  /// Get health check settings
  Future<HealthCheckSettings> getHealthCheckSettings();

  /// Update health check settings
  Future<Either<Failure, Unit>> updateHealthCheckSettings(HealthCheckSettings settings);
}