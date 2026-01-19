import 'package:coloncare/features/bmi/domain/entities/bmi_record.dart';
import 'package:coloncare/features/bmi/domain/repositories/bmi_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

class CalculateBmiUseCase {
  final BmiRepository repository;

  CalculateBmiUseCase(this.repository);

  Future<Either<Failure, BmiRecord>> call({
    required double weight,
    required double height,
    String? notes,
  }) {
    return repository.calculateAndSaveBmi(
      weight: weight,
      height: height,
      notes: notes,
    );
  }
}