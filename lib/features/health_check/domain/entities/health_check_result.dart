import 'package:equatable/equatable.dart';

enum RiskLevel {
  low,
  medium,
  high,
}

class HealthCheckResult extends Equatable {
  final String id;
  final Map<String, String> answers;
  final int score;
  final RiskLevel riskLevel;
  final DateTime timestamp;

  const HealthCheckResult({
    required this.id,
    required this.answers,
    required this.score,
    required this.riskLevel,
    required this.timestamp,
  });

  String get riskDescription {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'You\'re doing well! Keep up the good work.';
      case RiskLevel.medium:
        return 'Please monitor your symptoms closely. Consider contacting your doctor if symptoms persist.';
      case RiskLevel.high:
        return 'Please contact your doctor as soon as possible for further evaluation.';
    }
  }

  bool get shouldCallDoctor => riskLevel == RiskLevel.high || riskLevel == RiskLevel.medium;

  @override
  List<Object> get props => [id, answers, score, riskLevel, timestamp];
}