import 'package:coloncare/features/predict/domain/entities/prediction_history_entry.dart';
import 'package:coloncare/features/predict/domain/repositories/prediction_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

class GetPredictionHistoryUseCase {
  final PredictionRepository repository;

  GetPredictionHistoryUseCase(this.repository);

  Future<Either<Failure, List<PredictionHistoryEntry>>> call() {
    return repository.getPredictionHistory();
  }
}