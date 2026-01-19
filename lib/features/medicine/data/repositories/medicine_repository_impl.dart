import 'package:dartz/dartz.dart';
import '../../domain/entities/medicine_reminder.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_remote_data_source.dart';
import '../../../../core/failures/failure.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource remote;

  MedicineRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, MedicineReminder>> saveMedicine(
      MedicineReminder reminder,
      ) async {
    try {
      final result = await remote.saveMedicine(reminder);
      return Right(result);
    } catch (e, stack) {
      return Left(MedicineFailure('Failed to save medicine: $e', stackTrace: stack));
    }
  }

  @override
  Stream<Either<Failure, List<MedicineReminder>>> watchAllMedicines(String userId) {
    return remote.watchAllMedicines(userId)
        .map((medicines) => Right<Failure, List<MedicineReminder>>(medicines))
        .handleError((error, stack) {
      return Left(MedicineFailure('Failed to watch medicines: $error', stackTrace: stack));
    });
  }

  @override
  Future<Either<Failure, List<MedicineReminder>>> getAllMedicines(
      String userId,
      ) async {
    try {
      final result = await remote.getAllMedicines(userId);
      return Right(result);
    } catch (e, stack) {
      return Left(MedicineFailure('Failed to load medicines: $e', stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, List<MedicineReminder>>> getMedicinesForDay(
      String userId,
      DateTime day,
      ) async {
    try {
      final result = await remote.getMedicinesForDay(userId, day);
      return Right(result);
    } catch (e, stack) {
      return Left(MedicineFailure('Failed to load medicines for day: $e', stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, Unit>> recordTakenStatus(TakenStatus status) async {
    try {
      await remote.recordTakenStatus(status);
      return const Right(unit);
    } catch (e, stack) {
      return Left(MedicineFailure('Failed to record taken status: $e', stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, List<TakenStatus>>> getTakenStatusForDay(
      String userId,
      DateTime day,
      ) async {
    try {
      final result = await remote.getTakenStatusForDay(userId, day);
      return Right(result);
    } catch (e, stack) {
      return Left(MedicineFailure('Failed to load taken status: $e', stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMedicine(String medicineId) async {
    try {
      await remote.deleteMedicine(medicineId);
      return const Right(unit);
    } catch (e, stack) {
      return Left(MedicineFailure('Failed to delete medicine: $e', stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, Unit>> setActiveStatus(
      String medicineId, {
        required bool active,
      }) async {
    try {
      await remote.setActiveStatus(medicineId, active: active);
      return const Right(unit);
    } catch (e, stack) {
      return Left(MedicineFailure('Failed to update active status: $e', stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateLastTaken({
    required String medicineId,
    required DateTime takenAt,
    required bool isFirstDoseOfDay,
  }) async {
    try {
      await remote.updateLastTaken(
        medicineId: medicineId,
        takenAt: takenAt,
        isFirstDoseOfDay: isFirstDoseOfDay,
      );
      return const Right(unit);
    } catch (e, stack) {
      return Left(MedicineFailure('Failed to update last taken time: $e', stackTrace: stack));
    }
  }
}

class MedicineFailure extends Failure {
  const MedicineFailure(super.message, {stackTrace});
}