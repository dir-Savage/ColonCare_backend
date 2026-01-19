// features/prediction/domain/entities/prediction_result.dart
import 'package:equatable/equatable.dart';

class PredictionResult extends Equatable {
  final String prediction;        // e.g. "Normal", "Polyp", "Cancer", ...
  final double probability;       // 0.0 to 1.0
  final bool isOutOfDistribution; // true if model considers input unreliable
  final double distance;          // distance to nearest known class (if available)
  final String details;           // optional extra info from model

  const PredictionResult({
    required this.prediction,
    required this.probability,
    required this.isOutOfDistribution,
    required this.distance,
    required this.details,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      prediction: json['prediction'] as String,
      probability: (json['probability'] as num).toDouble(),
      isOutOfDistribution: json['is_ood'] as bool,
      distance: (json['distance'] as num).toDouble(),
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

  @override
  List<Object?> get props => [
    prediction,
    probability,
    isOutOfDistribution,
    distance,
    details,
  ];
}