import 'package:coloncare/core/failures/failure.dart';
import 'package:coloncare/features/bmi/data/datasources/bmi_local_data_source.dart';
import 'package:coloncare/features/bmi/domain/entities/bmi_record.dart';
import 'package:coloncare/features/bmi/domain/repositories/bmi_repository.dart';
import 'package:dartz/dartz.dart';

class ValidationFailure extends Failure {
  final String message;

  ValidationFailure(this.message) : super(message);

  @override
  List<Object> get props => [message];
}

class BmiRepositoryImpl implements BmiRepository {
  final BmiLocalDataSource localDataSource;

  BmiRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, BmiRecord>> calculateAndSaveBmi({
    required double weight,
    required double height,
    String? notes,
  }) async {
    try {
      // Validate inputs
      if (weight <= 0 || height <= 0) {
        return Left(ValidationFailure('Please enter valid weight and height values'));
      }

      if (weight > 300) {
        return Left(ValidationFailure('Weight cannot exceed 300 kg'));
      }

      if (height > 300) {
        return Left(ValidationFailure('Height cannot exceed 300 cm'));
      }

      // Create and save record
      final record = BmiRecord.create(
        weight: weight,
        height: height,
        notes: notes,
      );

      await localDataSource.saveBmiRecord(record);
      return Right(record);
    } catch (e) {
      return Left(ValidationFailure('Failed to calculate BMI: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BmiRecord>>> getBmiHistory() async {
    try {
      final records = await localDataSource.getBmiHistory();
      return Right(records);
    } catch (e) {
      return Left(ValidationFailure('Failed to load BMI history: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteBmiRecord(String id) async {
    try {
      await localDataSource.deleteBmiRecord(id);
      return const Right(unit);
    } catch (e) {
      return Left(ValidationFailure('Failed to delete BMI record: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearBmiHistory() async {
    try {
      await localDataSource.clearBmiHistory();
      return const Right(unit);
    } catch (e) {
      return Left(ValidationFailure('Failed to clear BMI history: ${e.toString()}'));
    }
  }
}