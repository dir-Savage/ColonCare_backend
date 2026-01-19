import 'package:coloncare/features/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/failures/failure.dart';
import '../entities/medicine_reminder.dart';
import '../repositories/medicine_repository.dart';

class GetTakenStatusForDayUseCase {
  final MedicineRepository repository;
  const GetTakenStatusForDayUseCase(this.repository);

  Future<Either<Failure, List<TakenStatus>>> call({
    required String userId,
    required DateTime day,
  }) {
    if (userId.trim().isEmpty) {
      return Future.value(Left(ValidationFailure('User ID is required')));
    }

    final normalizedDay = DateTime(day.year, day.month, day.day);
    return repository.getTakenStatusForDay(userId, normalizedDay);
  }
}