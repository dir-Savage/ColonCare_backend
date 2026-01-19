import 'package:coloncare/features/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/failures/failure.dart';
import '../repositories/medicine_repository.dart';

class ToggleActiveStatusUseCase {
  final MedicineRepository repository;
  const ToggleActiveStatusUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String medicineId,
    required bool active,
  }) {
    if (medicineId.trim().isEmpty) {
      return Future.value(Left(ValidationFailure('Medicine ID is required')));
    }
    return repository.setActiveStatus(medicineId, active: active);
  }
}