import 'package:coloncare/features/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/failures/failure.dart';
import '../entities/medicine_reminder.dart';
import '../repositories/medicine_repository.dart';

class SaveMedicineUseCase {
  final MedicineRepository repository;
  const SaveMedicineUseCase(this.repository);

  Future<Either<Failure, MedicineReminder>> call(MedicineReminder reminder) async {
    if (reminder.title.trim().isEmpty) {
      return Left(ValidationFailure('Medicine name is required'));
    }
    if (reminder.purpose.trim().isEmpty) {
      return Left(ValidationFailure('Purpose is required'));
    }
    if (reminder.hourInterval <= 0) {
      return Left(ValidationFailure('Interval must be positive'));
    }
    if (![1, 2, 3, 4, 6, 8, 12, 24].contains(reminder.hourInterval)) {
      return Left(ValidationFailure('Please choose a standard interval (1–24h)'));
    }
    return repository.saveMedicine(reminder);
  }
}