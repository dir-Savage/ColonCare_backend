import 'dart:io';
import 'package:coloncare/features/predict/domain/entities/prediction_result.dart';
import 'package:coloncare/features/predict/domain/repositories/prediction_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

class MakePredictionUseCase {
  final PredictionRepository repository;

  MakePredictionUseCase(this.repository);

  Future<Either<Failure, PredictionResult>> call(File imageFile) {
    return repository.makePrediction(imageFile);
  }
}