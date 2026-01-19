// features/prediction/domain/usecases/delete_prediction_usecase.dart
import 'package:coloncare/features/predict/domain/repositories/prediction_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

class DeletePredictionUseCase {
  final PredictionRepository repository;

  DeletePredictionUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String historyId) {
    return repository.deletePrediction(historyId);
  }
}