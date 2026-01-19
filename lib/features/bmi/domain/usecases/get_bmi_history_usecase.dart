import 'package:coloncare/features/bmi/domain/entities/bmi_record.dart';
import 'package:coloncare/features/bmi/domain/repositories/bmi_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

class GetBmiHistoryUseCase {
  final BmiRepository repository;

  GetBmiHistoryUseCase(this.repository);

  Future<Either<Failure, List<BmiRecord>>> call() {
    return repository.getBmiHistory();
  }
}