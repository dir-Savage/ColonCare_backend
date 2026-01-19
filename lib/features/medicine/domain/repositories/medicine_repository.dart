import 'package:coloncare/core/failures/failure.dart';
import 'package:dartz/dartz.dart';
import '../entities/medicine_reminder.dart';

abstract interface class MedicineRepository {
  /// Create or update medicine reminder
  Future<Either<Failure, MedicineReminder>> saveMedicine(MedicineReminder reminder);

  /// Watch all reminders for the user (realtime updates)
  Stream<Either<Failure, List<MedicineReminder>>> watchAllMedicines(String userId);

  /// Get all reminders for the user
  Future<Either<Failure, List<MedicineReminder>>> getAllMedicines(String userId);

  /// Get reminders that should appear on a specific day
  Future<Either<Failure, List<MedicineReminder>>> getMedicinesForDay(
      String userId,
      DateTime day,
      );

  /// Record whether a dose was taken (or skipped) on a specific day
  Future<Either<Failure, Unit>> recordTakenStatus(TakenStatus status);

  /// Get taken/skipped records for a specific day
  Future<Either<Failure, List<TakenStatus>>> getTakenStatusForDay(
      String userId,
      DateTime day,
      );

  /// Permanently delete a medicine reminder
  Future<Either<Failure, Unit>> deleteMedicine(String medicineId);

  /// Pause or resume a medicine reminder
  Future<Either<Failure, Unit>> setActiveStatus(String medicineId, {required bool active});

  /// Update the last taken timestamp (usually called after marking taken)
  Future<Either<Failure, Unit>> updateLastTaken({
    required String medicineId,
    required DateTime takenAt,
    required bool isFirstDoseOfDay,
  });
}