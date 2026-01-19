import 'package:coloncare/core/failures/failure.dart';
import 'package:coloncare/features/health_check/data/datasource/health_check_local_data_source.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_result.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_settings.dart';
import 'package:coloncare/features/health_check/domain/repositories/health_check_repository.dart';
import 'package:dartz/dartz.dart';

class HealthCheckRepositoryImpl implements HealthCheckRepository {
  final HealthCheckLocalDataSource localDataSource;

  HealthCheckRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> shouldShowQuestions() async {
    try {
      final settings = await localDataSource.getHealthCheckSettings();

      // If health check is disabled
      if (!settings.isEnabled) return false;

      final lastCheck = await localDataSource.getLastCheckTime();

      // First time or no previous check
      if (lastCheck == null) {
        return settings.showOnAppStart;
      }

      final now = DateTime.now();

      // Check if it's a new day (different calendar day)
      final bool isNewDay = now.day != lastCheck.day ||
          now.month != lastCheck.month ||
          now.year != lastCheck.year;

      // Show on first opening of the day if enabled
      if (isNewDay && settings.showOnAppStart) {
        return true;
      }

      // Check custom interval
      final timeSinceLastCheck = now.difference(lastCheck);
      return timeSinceLastCheck >= settings.checkInterval;
    } catch (e) {
      return true; // Default to showing questions on error
    }
  }

  @override
  Future<Duration> getTimeUntilNextCheck() async {
    try {
      final settings = await localDataSource.getHealthCheckSettings();
      final lastCheck = await localDataSource.getLastCheckTime();

      if (lastCheck == null) return Duration.zero;

      final now = DateTime.now();
      final bool isNewDay = now.day != lastCheck.day ||
          now.month != lastCheck.month ||
          now.year != lastCheck.year;

      // If it's a new day and showOnAppStart is enabled
      if (isNewDay && settings.showOnAppStart) {
        return Duration.zero;
      }

      // Otherwise check custom interval
      final timeSinceLastCheck = now.difference(lastCheck);
      final timeUntilNext = settings.checkInterval - timeSinceLastCheck;

      return timeUntilNext.isNegative ? Duration.zero : timeUntilNext;
    } catch (e) {
      return Duration.zero;
    }
  }

  @override
  Future<Either<Failure, Unit>> saveHealthCheckResult(HealthCheckResult result) async {
    try {
      await localDataSource.saveHealthCheckResult(result);
      await localDataSource.saveLastCheckTime(DateTime.now());
      return const Right(unit);
    } catch (e) {
      return Left(HealthCheckFailure('Failed to save health check result: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HealthCheckResult>>> getHealthCheckHistory() async {
    try {
      final history = await localDataSource.getHealthCheckHistory();
      return Right(history);
    } catch (e) {
      return Left(HealthCheckFailure('Failed to load health check history: $e'));
    }
  }

  @override
  Future<HealthCheckSettings> getHealthCheckSettings() async {
    try {
      return await localDataSource.getHealthCheckSettings();
    } catch (e) {
      return HealthCheckSettings.defaultSettings();
    }
  }

  @override
  Future<Either<Failure, Unit>> updateHealthCheckSettings(HealthCheckSettings settings) async {
    try {
      await localDataSource.saveHealthCheckSettings(settings);
      return const Right(unit);
    } catch (e) {
      return Left(HealthCheckFailure('Failed to update health check settings: $e'));
    }
  }
}

class HealthCheckFailure extends Failure {
  const HealthCheckFailure(super.message);
}