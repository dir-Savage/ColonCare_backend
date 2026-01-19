// features/prediction/data/models/prediction_history_entry_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coloncare/features/predict/data/models/prediction_result_model.dart';
import 'package:coloncare/features/predict/domain/entities/prediction_history_entry.dart';

class PredictionHistoryEntryModel extends PredictionHistoryEntry {
  const PredictionHistoryEntryModel({
    required super.id,
    required super.userId,
    required super.base64Image,
    required super.result,
    required super.createdAt,
  });

  factory PredictionHistoryEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw const FormatException('Document has no data');
    }

    return PredictionHistoryEntryModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      base64Image: data['image'] as String? ?? '',
      result: PredictionResultModel.fromJson(
        data['result'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'image': base64Image,
    'result': (result as PredictionResultModel).toJson(),
    'createdAt': Timestamp.fromDate(createdAt),
  };
}