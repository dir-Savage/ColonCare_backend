import 'package:equatable/equatable.dart';

abstract class BmiEvent extends Equatable {
  const BmiEvent();

  @override
  List<Object> get props => [];
}

class BmiCalculateRequested extends BmiEvent {
  final double weight;
  final double height;
  final String? notes;

  const BmiCalculateRequested({
    required this.weight,
    required this.height,
    this.notes,
  });

  @override
  List<Object> get props => [weight, height, notes ?? ''];
}

class BmiHistoryRequested extends BmiEvent {
  const BmiHistoryRequested();
}

class BmiRecordDeleted extends BmiEvent {
  final String id;

  const BmiRecordDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class BmiHistoryCleared extends BmiEvent {
  const BmiHistoryCleared();
}

class BmiInputChanged extends BmiEvent {
  final double? weight;
  final double? height;
  final String? notes;

  const BmiInputChanged({
    this.weight,
    this.height,
    this.notes,
  });

  @override
  List<Object> get props => [
    weight ?? 0.0,
    height ?? 0.0,
    notes ?? '',
  ];
}

class BmiErrorCleared extends BmiEvent {
  const BmiErrorCleared();
}