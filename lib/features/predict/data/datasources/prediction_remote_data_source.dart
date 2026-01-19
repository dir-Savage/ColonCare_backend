// features/prediction/data/datasources/prediction_remote_data_source.dart
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coloncare/core/failures/failure.dart';
import 'package:coloncare/core/utils/image_utils.dart';
import 'package:coloncare/features/predict/data/models/prediction_history_entry_model.dart';
import 'package:coloncare/features/predict/data/models/prediction_result_model.dart';
import 'package:coloncare/features/predict/domain/failures/prediction_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

abstract class PredictionRemoteDataSource {
  Future<PredictionResultModel> predictFromImage(File imageFile);

  Future<String> encodeImageToBase64(File imageFile);

  Future<void> savePrediction({
    required String userId,
    required String base64Image,
    required PredictionResultModel result,
  });
  Future<List<PredictionHistoryEntryModel>> getPredictionHistory(String userId);

  Future<void> deletePrediction(String predictionId);
}

class PredictionRemoteDataSourceImpl implements PredictionRemoteDataSource {
  final http.Client httpClient;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  static const String _apiBaseUrl =
      "https://kitchen-cambridge-assistant-nsw.trycloudflare.com/predict";

  PredictionRemoteDataSourceImpl({
    required this.httpClient,
    required this.firestore,
    required this.auth,
  });

  @override
  Future<PredictionResultModel> predictFromImage(File imageFile) async {
    try {
      final compressedBytes = await ImageUtils.compressImage(imageFile);
      final base64Image = base64Encode(compressedBytes);

      final response = await httpClient.post(
        Uri.parse(_apiBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode != 200) {
        print(
            "Prediction API failed (${response.statusCode}): ${response.body}");
        throw ApiRequestFailed(
          'Prediction API failed (${response.statusCode}): ${response.body}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PredictionResultModel.fromJson(json);
    } catch (e) {
      if (e is Failure) rethrow;
      throw PredictionServerError('Failed to reach prediction server: $e');
    }
  }

  @override
  Future<String> encodeImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw const StorageUploadFailed('Failed to encode image to base64');
    }
  }

  @override
  Future<void> savePrediction({
    required String userId,
    required String base64Image,
    required PredictionResultModel result,
  }) async {
    try {
      await firestore.collection('predictions').add({
        'userId': userId,
        'image': base64Image,
        'result': result.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreWriteFailed('Failed to save prediction to Firestore: $e');
    }
  }

  @override
  Future<List<PredictionHistoryEntryModel>> getPredictionHistory(
      String userId) async {
    try {
      final snapshot = await firestore
          .collection('predictions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return PredictionHistoryEntryModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw FirestoreFetchFailed('Failed to fetch prediction history: $e');
    }
  }

  @override
  Future<void> deletePrediction(String predictionId) async {
    try {
      await firestore.collection('predictions').doc(predictionId).delete();
    } catch (e) {
      throw FirestoreWriteFailed('Failed to delete prediction: $e');
    }
  }
}