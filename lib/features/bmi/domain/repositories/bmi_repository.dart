import 'package:coloncare/features/bmi/domain/entities/bmi_record.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

abstract class BmiRepository {
  /// Calculate and save a new BMI record
  Future<Either<Failure, BmiRecord>> calculateAndSaveBmi({
    required double weight,
    required double height,
    String? notes,
  });

  /// Get all BMI records (sorted by date, newest first)
  Future<Either<Failure, List<BmiRecord>>> getBmiHistory();

  /// Delete a BMI record by ID
  Future<Either<Failure, Unit>> deleteBmiRecord(String id);

  /// Clear all BMI history
  Future<Either<Failure, Unit>> clearBmiHistory();
}