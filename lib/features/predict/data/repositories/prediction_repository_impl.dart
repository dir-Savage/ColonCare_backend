import 'dart:io';
import 'package:coloncare/core/failures/failure.dart';
import 'package:coloncare/features/predict/data/datasources/prediction_local_data_source.dart';
import 'package:coloncare/features/predict/data/datasources/prediction_remote_data_source.dart';
import 'package:coloncare/features/predict/domain/entities/prediction_history_entry.dart';
import 'package:coloncare/features/predict/domain/entities/prediction_result.dart';
import 'package:coloncare/features/predict/domain/repositories/prediction_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class PredictionRepositoryImpl implements PredictionRepository {
  final PredictionRemoteDataSource remoteDataSource;
  final PredictionLocalDataSource localDataSource;
  final FirebaseAuth auth;

  PredictionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.auth,
  });

  @override
  Future<Either<Failure, PredictionResult>> makePrediction(
      File imageFile) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      // 1. Get prediction from API
      final result = await remoteDataSource.predictFromImage(imageFile);

      // 2. Encode image to base64 (can be optimized later to avoid reading twice)
      final base64Image = await remoteDataSource.encodeImageToBase64(imageFile);

      // 3. Save to Firestore
      await remoteDataSource.savePrediction(
        userId: currentUser.uid,
        base64Image: base64Image,
        result: result,
      );

      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<PredictionHistoryEntry>>>
  getPredictionHistory() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      // Optional: check cache first
      final cached = await localDataSource.getCachedHistory();
      if (cached != null && cached.isNotEmpty) {
        return Right(cached);
      }

      final history =
      await remoteDataSource.getPredictionHistory(currentUser.uid);

      // Optional: cache result
      await localDataSource.cacheHistory(history);

      return Right(history);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePrediction(String predictionId) async {
    try {
      await remoteDataSource.deletePrediction(predictionId);
      return const Right(unit);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(NetworkFailure());
    }
  }
}