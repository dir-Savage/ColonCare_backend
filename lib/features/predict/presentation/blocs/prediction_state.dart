part of 'prediction_bloc.dart';

abstract class PredictionState extends Equatable {
  const PredictionState();

  @override
  List<Object> get props => [];
}

class PredictionInitial extends PredictionState {}

class PredictionInputState extends PredictionState {
  final File? selectedImage;

  const PredictionInputState({this.selectedImage});

  @override
  List<Object> get props => [selectedImage ?? File('')];
}

class PredictionLoading extends PredictionState {
  final File selectedImage;

  const PredictionLoading({required this.selectedImage});

  @override
  List<Object> get props => [selectedImage];
}

class PredictionSuccess extends PredictionState {
  final PredictionResult result;
  final File selectedImage;

  const PredictionSuccess({
    required this.result,
    required this.selectedImage,
  });

  @override
  List<Object> get props => [result, selectedImage];
}

class PredictionError extends PredictionState {
  final String message;
  final File? selectedImage;

  const PredictionError({
    required this.message,
    this.selectedImage,
  });

  @override
  List<Object> get props => [message, selectedImage ?? File('')];
}

class HistoryLoading extends PredictionState {}

class HistoryLoaded extends PredictionState {
  final List<PredictionHistoryEntry> history;

  const HistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class HistoryError extends PredictionState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}