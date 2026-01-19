import 'package:coloncare/features/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/failures/failure.dart';
import '../repositories/medicine_repository.dart';

class DeleteMedicineUseCase {
  final MedicineRepository repository;
  const DeleteMedicineUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String medicineId) {
    if (medicineId.trim().isEmpty) {
      return Future.value(Left(ValidationFailure('Medicine ID is required')));
    }
    return repository.deleteMedicine(medicineId);
  }
}