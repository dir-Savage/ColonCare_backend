part of 'prediction_bloc.dart';

abstract class PredictionEvent extends Equatable {
  const PredictionEvent();

  @override
  List<Object> get props => [];
}

class PredictFromImage extends PredictionEvent {
  final File imageFile;

  const PredictFromImage(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class PredictionImageSelected extends PredictionEvent {
  final File selectedImage;

  const PredictionImageSelected(this.selectedImage);

  @override
  List<Object> get props => [selectedImage];
}

class LoadPredictionHistory extends PredictionEvent {
  const LoadPredictionHistory();
}

class DeletePrediction extends PredictionEvent {
  final String predictionId;

  const DeletePrediction(this.predictionId);

  @override
  List<Object> get props => [predictionId];
}

class ClearPredictionState extends PredictionEvent {
  const ClearPredictionState();
}