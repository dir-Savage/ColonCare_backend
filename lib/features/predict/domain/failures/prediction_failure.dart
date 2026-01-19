// features/prediction/domain/failures/prediction_failure.dart
import 'package:coloncare/core/failures/failure.dart';

abstract class PredictionFailure extends Failure {
  const PredictionFailure(super.message);
}

class ImagePickingCancelled extends PredictionFailure {
  const ImagePickingCancelled() : super('Image selection cancelled by user');
}

class InvalidImageFormat extends PredictionFailure {
  const InvalidImageFormat() : super('Unsupported image format');
}

class ApiRequestFailed extends PredictionFailure {
  const ApiRequestFailed(super.message);
}

class PredictionServerError extends PredictionFailure {
  const PredictionServerError(super.message);
}

class StorageUploadFailed extends PredictionFailure {
  const StorageUploadFailed(super.message);
}

class FirestoreWriteFailed extends PredictionFailure {
  const FirestoreWriteFailed(super.message);
}

class FirestoreFetchFailed extends PredictionFailure {
  const FirestoreFetchFailed(super.message);
}