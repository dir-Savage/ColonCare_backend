import 'package:coloncare/features/predict/domain/entities/prediction_result.dart';
import 'package:equatable/equatable.dart';

class PredictionHistoryEntry extends Equatable {
  final String id;                    // Firestore document ID
  final String userId;
  final String base64Image;
  final PredictionResult result;
  final DateTime createdAt;

  const PredictionHistoryEntry({
    required this.id,
    required this.userId,
    required this.base64Image,
    required this.result,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, base64Image, result, createdAt];
}