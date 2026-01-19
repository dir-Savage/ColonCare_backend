import 'package:dartz/dartz.dart';
import '../../../../core/failures/failure.dart';
import '../entities/medicine_reminder.dart';
import '../repositories/medicine_repository.dart';

class MarkMedicineTakenUseCase {
  final MedicineRepository _repository;
  const MarkMedicineTakenUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String medicineId,
    required bool taken,
    required bool isFirstDoseOfDay,
  }) async {
    final now = DateTime.now();
    final status = TakenStatus(
      medicineId: medicineId,
      date: DateTime(now.year, now.month, now.day),
      taken: taken,
      takenAt: taken ? now : null,
      isFirstDoseOfTheDay: isFirstDoseOfDay,
    );

    // 1. Save daily taken status
    final statusResult = await _repository.recordTakenStatus(status);
    if (statusResult.isLeft()) return statusResult;

    // 2. If taken → update lastTaken timestamp on medicine
    if (taken) {
      return _repository.updateLastTaken(
        medicineId: medicineId,
        takenAt: now,
        isFirstDoseOfDay: isFirstDoseOfDay,
      );
    }

    return const Right(unit);
  }
}