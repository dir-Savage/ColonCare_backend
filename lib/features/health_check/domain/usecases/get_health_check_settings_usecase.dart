import 'package:coloncare/features/health_check/domain/entities/health_check_settings.dart';
import 'package:coloncare/features/health_check/domain/repositories/health_check_repository.dart';

class GetHealthCheckSettingsUseCase {
  final HealthCheckRepository repository;

  GetHealthCheckSettingsUseCase(this.repository);

  Future<HealthCheckSettings> call() {
    return repository.getHealthCheckSettings();
  }
}