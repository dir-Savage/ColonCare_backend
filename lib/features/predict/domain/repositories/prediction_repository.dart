// features/prediction/domain/repositories/prediction_repository.dart
import 'dart:io';

import 'package:coloncare/features/predict/domain/entities/prediction_history_entry.dart';
import 'package:coloncare/features/predict/domain/entities/prediction_result.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

abstract class PredictionRepository {
  /// Picks an image from gallery/camera, encodes it to base64, calls the ML API,
  /// uploads image to Firebase Storage, saves result to Firestore
  Future<Either<Failure, PredictionResult>> makePrediction(File imageFile);

  /// Fetches all prediction history for the current user, sorted by date (newest first)
  Future<Either<Failure, List<PredictionHistoryEntry>>> getPredictionHistory();

  /// Deletes a specific prediction record (both Firestore doc + Storage file)
  Future<Either<Failure, Unit>> deletePrediction(String historyId);
}