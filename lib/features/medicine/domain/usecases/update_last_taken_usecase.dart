import 'package:coloncare/features/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/failures/failure.dart';
import '../repositories/medicine_repository.dart';

class UpdateLastTakenUseCase {
  final MedicineRepository repository;
  const UpdateLastTakenUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String medicineId,
    required DateTime takenAt,
    required bool isFirstDoseOfDay,
  }) {
    if (medicineId.trim().isEmpty) {
      return Future.value(Left(ValidationFailure('Medicine ID is required')));
    }
    if (takenAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return Future.value(Left(ValidationFailure('Taken time cannot be in the future')));
    }
    return repository.updateLastTaken(
      medicineId: medicineId,
      takenAt: takenAt,
      isFirstDoseOfDay: isFirstDoseOfDay,
    );
  }
}