// features/prediction/data/models/prediction_result_model.dart
import 'package:coloncare/features/predict/domain/entities/prediction_result.dart';

class PredictionResultModel extends PredictionResult {
  const PredictionResultModel({
    required super.prediction,
    required super.probability,
    required super.isOutOfDistribution,
    required super.distance,
    required super.details,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    return PredictionResultModel(
      prediction: json['prediction'] as String? ?? 'Unknown',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
      isOutOfDistribution: json['is_ood'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      details: json['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'prediction': prediction,
    'probability': probability,
    'is_ood': isOutOfDistribution,
    'distance': distance,
    'details': details,
  };
}