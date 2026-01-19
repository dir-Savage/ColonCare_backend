import 'package:bloc/bloc.dart';
import 'package:coloncare/features/bmi/domain/usecases/calculate_bmi_usecase.dart';
import 'package:coloncare/features/bmi/domain/usecases/get_bmi_history_usecase.dart';
import 'package:equatable/equatable.dart';

import 'bmi_event.dart';
import 'bmi_state.dart';

class BmiBloc extends Bloc<BmiEvent, BmiState> {
  final CalculateBmiUseCase calculateBmiUseCase;
  final GetBmiHistoryUseCase getBmiHistoryUseCase;

  BmiBloc({
    required this.calculateBmiUseCase,
    required this.getBmiHistoryUseCase,
  }) : super(const BmiInitial()) {
    on<BmiCalculateRequested>(_onBmiCalculateRequested);
    on<BmiHistoryRequested>(_onBmiHistoryRequested);
    on<BmiRecordDeleted>(_onBmiRecordDeleted);
    on<BmiHistoryCleared>(_onBmiHistoryCleared);
    on<BmiInputChanged>(_onBmiInputChanged);
    on<BmiErrorCleared>(_onBmiErrorCleared);
  }

  Future<void> _onBmiCalculateRequested(
      BmiCalculateRequested event,
      Emitter<BmiState> emit,
      ) async {
    emit(BmiLoading(
      weight: event.weight,
      height: event.height,
      notes: event.notes,
    ));

    try {
      final result = await calculateBmiUseCase(
        weight: event.weight,
        height: event.height,
        notes: event.notes,
      );

      result.fold(
            (failure) {
          emit(BmiError(failure.message));
        },
            (record) {
          // After successful calculation, reload history
          add(const BmiHistoryRequested());
        },
      );
    } catch (e) {
      emit(BmiError('Failed to calculate BMI: ${e.toString()}'));
    }
  }

  Future<void> _onBmiHistoryRequested(
      BmiHistoryRequested event,
      Emitter<BmiState> emit,
      ) async {
    emit(const BmiHistoryLoading());

    try {
      final result = await getBmiHistoryUseCase();

      result.fold(
            (failure) {
          emit(BmiHistoryError(failure.message));
        },
            (records) {
          emit(BmiHistoryLoaded(records: records));
        },
      );
    } catch (e) {
      emit(BmiHistoryError('Failed to load history: ${e.toString()}'));
    }
  }

  Future<void> _onBmiRecordDeleted(
      BmiRecordDeleted event,
      Emitter<BmiState> emit,
      ) async {
    if (state is BmiHistoryLoaded) {
      final currentState = state as BmiHistoryLoaded;
      final updatedRecords = currentState.records
          .where((record) => record.id != event.id)
          .toList();

      emit(BmiHistoryLoaded(records: updatedRecords));
    }
  }

  Future<void> _onBmiHistoryCleared(
      BmiHistoryCleared event,
      Emitter<BmiState> emit,
      ) async {
    emit(const BmiHistoryLoaded(records: []));
  }

  void _onBmiInputChanged(
      BmiInputChanged event,
      Emitter<BmiState> emit,
      ) {
    if (state is BmiInputState) {
      final currentState = state as BmiInputState;
      emit(currentState.copyWith(
        weight: event.weight ?? currentState.weight,
        height: event.height ?? currentState.height,
        notes: event.notes ?? currentState.notes,
      ));
    } else {
      emit(BmiInputState(
        weight: event.weight ?? 70.0,
        height: event.height ?? 170.0,
        notes: event.notes ?? '',
      ));
    }
  }

  void _onBmiErrorCleared(
      BmiErrorCleared event,
      Emitter<BmiState> emit,
      ) {
    if (state is BmiError) {
      emit(const BmiInputState());
    } else if (state is BmiHistoryError) {
      add(const BmiHistoryRequested());
    }
  }
}