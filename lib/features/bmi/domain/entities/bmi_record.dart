import 'package:equatable/equatable.dart';

class BmiRecord extends Equatable {
  final String id;
  final double weight; // in kg
  final double height; // in cm
  final double bmi;
  final String category;
  final DateTime date;
  final String? notes;

  const BmiRecord({
    required this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.category,
    required this.date,
    this.notes,
  });

  factory BmiRecord.create({
    required double weight,
    required double height,
    String? notes,
  }) {
    final bmi = _calculateBmi(weight, height);
    final category = _getBmiCategory(bmi);

    return BmiRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: weight,
      height: height,
      bmi: bmi,
      category: category,
      date: DateTime.now(),
      notes: notes,
    );
  }

  static double _calculateBmi(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    if (bmi < 35) return 'Obesity Class I';
    if (bmi < 40) return 'Obesity Class II';
    return 'Obesity Class III';
  }

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String get formattedTime {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  List<Object?> get props => [id, weight, height, bmi, category, date, notes];
}