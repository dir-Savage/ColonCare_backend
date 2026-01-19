import 'package:coloncare/features/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/failures/failure.dart';
import '../entities/medicine_reminder.dart';
import '../repositories/medicine_repository.dart';

class GetAllMedicinesUseCase {
  final MedicineRepository repository;
  const GetAllMedicinesUseCase(this.repository);

  Future<Either<Failure, List<MedicineReminder>>> call(String userId) {
    if (userId.trim().isEmpty) {
      return Future.value(Left(ValidationFailure('User ID is required')));
    }
    return repository.getAllMedicines(userId);
  }
}