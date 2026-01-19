import 'package:coloncare/features/bmi/domain/entities/bmi_record.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class BmiState extends Equatable {
  const BmiState();

  @override
  List<Object?> get props => [];
}

class BmiInitial extends BmiState {
  const BmiInitial();
}

class BmiInputState extends BmiState {
  final double weight;
  final double height;
  final String notes;
  final bool canCalculate;

  const BmiInputState({
    this.weight = 70.0,
    this.height = 170.0,
    this.notes = '',
  }) : canCalculate = weight > 0 && height > 0;

  BmiInputState copyWith({
    double? weight,
    double? height,
    String? notes,
  }) {
    return BmiInputState(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      notes: notes ?? this.notes,
    );
  }

  double get calculatedBmi {
    final heightM = height / 100;
    return weight / (heightM * heightM);
  }

  String get bmiCategory {
    final bmi = calculatedBmi;
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    if (bmi < 35) return 'Obesity Class I';
    if (bmi < 40) return 'Obesity Class II';
    return 'Obesity Class III';
  }

  Color get bmiColor {
    final bmi = calculatedBmi;
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  List<Object> get props => [weight, height, notes, canCalculate];
}

class BmiLoading extends BmiState {
  final double weight;
  final double height;
  final String? notes;

  const BmiLoading({
    required this.weight,
    required this.height,
    this.notes,
  });

  @override
  List<Object?> get props => [weight, height, notes];
}

class BmiCalculated extends BmiState {
  final BmiRecord record;

  const BmiCalculated(this.record);

  @override
  List<Object> get props => [record];
}

class BmiHistoryLoading extends BmiState {
  const BmiHistoryLoading();
}

class BmiHistoryLoaded extends BmiState {
  final List<BmiRecord> records;

  const BmiHistoryLoaded({required this.records});

  @override
  List<Object> get props => [records];
}

class BmiError extends BmiState {
  final String message;

  const BmiError(this.message);

  @override
  List<Object> get props => [message];
}

class BmiHistoryError extends BmiState {
  final String message;

  const BmiHistoryError(this.message);

  @override
  List<Object> get props => [message];
}