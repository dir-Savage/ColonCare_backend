// features/prediction/presentation/bloc/prediction_bloc.dart

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:coloncare/core/failures/failure.dart';
import 'package:coloncare/features/predict/domain/entities/prediction_history_entry.dart';
import 'package:coloncare/features/predict/domain/entities/prediction_result.dart';
import 'package:coloncare/features/predict/domain/usecases/delete_prediction_usecase.dart';
import 'package:coloncare/features/predict/domain/usecases/get_prediction_history_usecase.dart';
import 'package:coloncare/features/predict/domain/usecases/make_prediction_usecase.dart';
import 'package:equatable/equatable.dart';

part 'prediction_event.dart';
part 'prediction_state.dart';

class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  final MakePredictionUseCase makePredictionUseCase;
  final GetPredictionHistoryUseCase getPredictionHistoryUseCase;
  final DeletePredictionUseCase deletePredictionUseCase;

  PredictionBloc({
    required this.makePredictionUseCase,
    required this.getPredictionHistoryUseCase,
    required this.deletePredictionUseCase,
  }) : super(PredictionInitial()) {
    on<PredictFromImage>(_onPredictFromImage);
    on<PredictionImageSelected>(_onPredictionImageSelected);
    on<LoadPredictionHistory>(_onLoadPredictionHistory);
    on<DeletePrediction>(_onDeletePrediction);
    on<ClearPredictionState>(_onClearPredictionState);
  }

  Future<void> _onPredictionImageSelected(
      PredictionImageSelected event,
      Emitter<PredictionState> emit,
      ) async {
    emit(PredictionInputState(selectedImage: event.selectedImage));
  }

  Future<void> _onPredictFromImage(
      PredictFromImage event,
      Emitter<PredictionState> emit,
      ) async {
    emit(PredictionLoading(selectedImage: event.imageFile));

    try {
      final result = await makePredictionUseCase(event.imageFile);
      result.fold(
            (failure) => emit(PredictionError(
          message: failure.message,
          selectedImage: event.imageFile,
        )),
            (prediction) {
          emit(PredictionSuccess(
            result: prediction,
            selectedImage: event.imageFile,
          ));
          // After successful prediction, reload history
          add(const LoadPredictionHistory());
        },
      );
    } catch (e) {
      emit(PredictionError(
        message: e.toString(),
        selectedImage: event.imageFile,
      ));
    }
  }

  Future<void> _onLoadPredictionHistory(
      LoadPredictionHistory event,
      Emitter<PredictionState> emit,
      ) async {
    emit(HistoryLoading());

    try {
      final result = await getPredictionHistoryUseCase();
      result.fold(
            (failure) => emit(HistoryError(failure.message)),
            (history) => emit(HistoryLoaded(history)),
      );
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onDeletePrediction(
      DeletePrediction event,
      Emitter<PredictionState> emit,
      ) async {
    try {
      final result = await deletePredictionUseCase(event.predictionId);
      result.fold(
            (failure) => emit(HistoryError(failure.message)),
            (_) {
          // Reload history after delete
          add(const LoadPredictionHistory());
        },
      );
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  void _onClearPredictionState(
      ClearPredictionState event,
      Emitter<PredictionState> emit,
      ) {
    emit(PredictionInitial());
  }
}