import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:coloncare/core/failures/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/medicine_reminder.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../../domain/usecases/delete_medicine_usecase.dart';
import '../../domain/usecases/get_all_medicines_usecase.dart';
import '../../domain/usecases/get_taken_status_for_day_usecase.dart';
import '../../domain/usecases/get_todays_medicines_usecase.dart';
import '../../domain/usecases/mark_medicine_taken_usecase.dart';
import '../../domain/usecases/save_medicine_usecase.dart';
import '../../domain/usecases/toggle_active_status_usecase.dart';

import 'medicine_event.dart';
import 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final GetTodaysMedicinesUseCase getTodaysMedicines;
  final GetAllMedicinesUseCase getAllMedicines;
  final SaveMedicineUseCase saveMedicine;
  final DeleteMedicineUseCase deleteMedicine;
  final ToggleActiveStatusUseCase toggleActive;
  final MarkMedicineTakenUseCase markTaken;
  final GetTakenStatusForDayUseCase getTakenStatusForDay;
  final MedicineRepository medicineRepository;

  // final MedicineNotificationIntegrator _notificationIntegrator = MedicineNotificationIntegrator();

  StreamSubscription<Either<Failure, List<MedicineReminder>>>? _medicinesSubscription;

  MedicineBloc({
    required this.getTodaysMedicines,
    required this.getAllMedicines,
    required this.saveMedicine,
    required this.deleteMedicine,
    required this.toggleActive,
    required this.markTaken,
    required this.getTakenStatusForDay,
    required this.medicineRepository,
  }) : super(MedicineInitial()) {
    on<LoadTodaysMedicines>(_onLoadTodays);
    on<LoadAllMedicines>(_onLoadAll);
    on<WatchAllMedicines>(_onWatchAll);
    on<SaveMedicineEvent>(_onSaveMedicine);
    on<DeleteMedicineEvent>(_onDeleteMedicine);
    on<ToggleActiveEvent>(_onToggleActive);
    on<MarkTakenEvent>(_onMarkTaken);
    on<UpdateTakenStatusOptimistic>(_onUpdateOptimistic);
    on<ClearError>(_onClearError);
  }

  Future<String> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  Future<void> _onLoadTodays(
      LoadTodaysMedicines event,
      Emitter<MedicineState> emit,
      ) async {
    emit(MedicineLoading(
      medicines: state.medicines,
      takenMap: state.takenMap,
      optimisticTaken: state.optimisticTaken,
    ));

    try {
      final userId = await _getUserId();
      final medicinesRes = await getTodaysMedicines(userId);

      await medicinesRes.fold(
            (failure) async => emit(MedicineError(
          medicines: state.medicines,
          takenMap: state.takenMap,
          optimisticTaken: state.optimisticTaken,
          message: failure.message,
        )),
            (medicines) async {
          final takenRes = await getTakenStatusForDay(
            userId: userId,
            day: DateTime.now(),
          );

          final takenMap = takenRes.fold(
                (failure) => <String, bool>{},
                (statuses) => {
              for (final s in statuses) s.medicineId: s.taken,
            },
          );

          emit(TodaysMedicinesLoaded(
            medicines: medicines,
            takenMap: takenMap,
            optimisticTaken: state.optimisticTaken,
          ));
        },
      );
    } catch (e) {
      emit(MedicineError(
        medicines: state.medicines,
        takenMap: state.takenMap,
        optimisticTaken: state.optimisticTaken,
        message: 'Failed to load today\'s medicines: $e',
      ));
    }
  }

  Future<void> _onLoadAll(
      LoadAllMedicines event,
      Emitter<MedicineState> emit,
      ) async {
    emit(MedicineLoading(
      medicines: state.medicines,
      takenMap: state.takenMap,
      optimisticTaken: state.optimisticTaken,
      isFullList: true,
    ));

    try {
      final userId = await _getUserId();
      final result = await getAllMedicines(userId);
      result.fold(
            (failure) => emit(MedicineError(
          medicines: state.medicines,
          takenMap: state.takenMap,
          optimisticTaken: state.optimisticTaken,
          message: failure.message,
        )),
            (medicines) => emit(AllMedicinesLoaded(
          medicines: medicines,
          takenMap: state.takenMap,
          optimisticTaken: state.optimisticTaken,
        )),
      );
    } catch (e) {
      emit(MedicineError(
        medicines: state.medicines,
        takenMap: state.takenMap,
        optimisticTaken: state.optimisticTaken,
        message: 'Failed to load all medicines: $e',
      ));
    }
  }

  Future<void> _onWatchAll(
      WatchAllMedicines event,
      Emitter<MedicineState> emit,
      ) async {
    try {
      final userId = await _getUserId();

      _medicinesSubscription?.cancel();

      _medicinesSubscription = medicineRepository.watchAllMedicines(userId)
          .listen((result) {
        result.fold(
              (failure) => emit(MedicineError(
            medicines: state.medicines,
            takenMap: state.takenMap,
            optimisticTaken: state.optimisticTaken,
            message: failure.message,
          )),
              (medicines) {
            if (state is TodaysMedicinesLoaded) {
              emit(TodaysMedicinesLoaded(
                medicines: medicines,
                takenMap: state.takenMap,
                optimisticTaken: state.optimisticTaken,
              ));
            } else if (state is AllMedicinesLoaded) {
              emit(AllMedicinesLoaded(
                medicines: medicines,
                takenMap: state.takenMap,
                optimisticTaken: state.optimisticTaken,
              ));
            }
          },
        );
      });
    } catch (e) {
      emit(MedicineError(
        medicines: state.medicines,
        takenMap: state.takenMap,
        optimisticTaken: state.optimisticTaken,
        message: 'Failed to watch medicines: $e',
      ));
    }
  }

  Future<void> _onSaveMedicine(
      SaveMedicineEvent event,
      Emitter<MedicineState> emit,
      ) async {
    print("💊 SaveMedicineEvent received");
    print("  - Title: ${event.title}");
    print("  - Purpose: ${event.purpose}");
    print("  - Start Date: ${event.startDate}");
    print("  - Days: ${event.daysOfWeek}");
    print("  - Interval: ${event.hourInterval}h");

    emit(MedicineLoading(
      medicines: state.medicines,
      takenMap: state.takenMap,
      optimisticTaken: state.optimisticTaken,
    ));

    try {
      final userId = await _getUserId();

      // Create medicine reminder
      final reminder = MedicineReminder(
        id: event.medicineId ?? '',
        userId: userId,
        title: event.title.trim(),
        purpose: event.purpose.trim(),
        startDate: event.startDate,
        endDate: event.endDate,
        daysOfWeek: event.daysOfWeek,
        hourInterval: event.hourInterval,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Set first dose time to 8:00 AM by default if not set
        firstDoseTimeOfDay: const TimeOfDay(hour: 8, minute: 0),
      );

      print("📦 Created reminder: ${reminder.toJson()}");

      final result = await saveMedicine(reminder);

      result.fold(
            (failure) {
          print("❌ Save failed: ${failure.message}");
          emit(MedicineError(
            medicines: state.medicines,
            takenMap: state.takenMap,
            optimisticTaken: state.optimisticTaken,
            message: failure.message,
          ));
        },
            (savedReminder) async {
          print("✅ Medicine saved successfully, ID: ${savedReminder.id}");

          // SCHEDULE NOTIFICATIONS - FIXED PART
          try {
            print("🔔 Scheduling notifications for medicine: ${savedReminder.title}");
            print("  - Interval: ${savedReminder.hourInterval}h");
            print("  - Start Date: ${savedReminder.startDate}");
            print("  - Days: ${savedReminder.daysOfWeek}");
            print("  - First Dose Time: ${savedReminder.firstDoseTimeOfDay ?? 'Not set'}");

            // Ensure we have a first dose time
            final reminderWithTime = savedReminder.firstDoseTimeOfDay == null
                ? savedReminder.copyWith(firstDoseTimeOfDay: const TimeOfDay(hour: 8, minute: 0))
                : savedReminder;

            // await _notificationIntegrator.scheduleMedicineReminders(reminderWithTime);
            print("✅ Notifications scheduled successfully");
          } catch (e) {
            print("⚠️ Failed to schedule notifications: $e");
            // Don't fail the save operation if notifications fail
            // Just log the error and continue
          }

          // Add the new medicine to the current list
          final updatedMedicines = List<MedicineReminder>.from(state.medicines)
            ..add(savedReminder);

          // Check if it should appear today
          final today = DateTime.now();
          final isForToday = savedReminder.isScheduledOn(today);
          print("📅 Should appear today? $isForToday");

          emit(MedicineActionSuccess(
            medicines: updatedMedicines,
            takenMap: state.takenMap,
            optimisticTaken: state.optimisticTaken,
            message: 'Medicine saved successfully',
          ));

          // Reload both lists to ensure consistency
          add(const LoadTodaysMedicines());
          add(const LoadAllMedicines());
        },
      );
    } catch (e, stack) {
      print("💥 Save medicine error: $e\n$stack");
      emit(MedicineError(
        medicines: state.medicines,
        takenMap: state.takenMap,
        optimisticTaken: state.optimisticTaken,
        message: 'Failed to save medicine: $e',
      ));
    }
  }

  Future<void> _onDeleteMedicine(
      DeleteMedicineEvent event,
      Emitter<MedicineState> emit,
      ) async {
    try {
      // CANCEL NOTIFICATIONS FIRST
      print("🗑️ Deleting medicine: ${event.medicineId}");
      // await _notificationIntegrator.cancelMedicineReminders(event.medicineId);
      print("✅ Notifications cancelled");

      final result = await deleteMedicine(event.medicineId);
      result.fold(
            (failure) => emit(MedicineError(
          medicines: state.medicines,
          takenMap: state.takenMap,
          optimisticTaken: state.optimisticTaken,
          message: failure.message,
        )),
            (_) => emit(MedicineActionSuccess(
          medicines: state.medicines,
          takenMap: state.takenMap,
          optimisticTaken: state.optimisticTaken,
          message: 'Medicine deleted',
        )),
      );
    } catch (e) {
      print("❌ Delete failed: $e");
      emit(MedicineError(
        medicines: state.medicines,
        takenMap: state.takenMap,
        optimisticTaken: state.optimisticTaken,
        message: 'Delete failed: $e',
      ));
    }
  }

  Future<void> _onToggleActive(
      ToggleActiveEvent event,
      Emitter<MedicineState> emit,
      ) async {
    try {
      // Find the medicine to update
      final medicine = state.medicines.firstWhere((m) => m.id == event.medicineId);

      // Update medicines list optimistically
      final updatedMedicines = state.medicines.map((med) {
        if (med.id == event.medicineId) {
          return med.copyWith(isActive: event.active);
        }
        return med;
      }).toList();

      // Emit updated state with optimistic change
      emit(_createUpdatedState(
        updatedMedicines,
        takenMap: state.takenMap,
        optimisticTaken: state.optimisticTaken,
      ));

      final result = await toggleActive(
        medicineId: event.medicineId,
        active: event.active,
      );

      result.fold(
            (failure) {
          // Revert on error - go back to original medicines
          emit(MedicineError(
            medicines: state.medicines, // Original state
            takenMap: state.takenMap,
            optimisticTaken: state.optimisticTaken,
            message: failure.message,
          ));
        },
            (_) async {
          // Success - keep the updated state

          // Update notifications based on new active status
          try {
            if (event.active) {
              print("▶️ Activating medicine: ${medicine.title}");
              // Reschedule notifications
              final updatedMedicine = medicine.copyWith(isActive: true);
              // await _notificationIntegrator.scheduleMedicineReminders(updatedMedicine);
              print("✅ Notifications scheduled for activated medicine");
            } else {
              print("⏸️ Pausing medicine: ${medicine.title}");
              // Cancel notifications
              // await _notificationIntegrator.cancelMedicineReminders(medicine.id);
              print("✅ Notifications cancelled for paused medicine");
            }
          } catch (e) {
            print("⚠️ Failed to update notifications: $e");
          }

          emit(MedicineActionSuccess(
            medicines: updatedMedicines,
            takenMap: state.takenMap,
            optimisticTaken: state.optimisticTaken,
            message: 'Medicine ${event.active ? 'activated' : 'paused'}',
          ));
        },
      );
    } catch (e) {
      print("❌ Toggle active failed: $e");
      // Revert on exception
      emit(MedicineError(
        medicines: state.medicines,
        takenMap: state.takenMap,
        optimisticTaken: state.optimisticTaken,
        message: 'Toggle failed: $e',
      ));
    }
  }

  Future<void> _onMarkTaken(
      MarkTakenEvent event,
      Emitter<MedicineState> emit,
      ) async {
    try {
      print("MarkTakenEvent received: medicineId=${event.medicineId}, taken=${event.taken}, isFirstDoseOfDay=${event.isFirstDoseOfDay}");

      final result = await markTaken(
        medicineId: event.medicineId,
        taken: event.taken,
        isFirstDoseOfDay: event.isFirstDoseOfDay,
      );

      result.fold(
            (failure) {
          print("MarkTaken failed: ${failure.message}");
          emit(MedicineError(
            medicines: state.medicines,
            takenMap: state.takenMap,
            optimisticTaken: state.optimisticTaken,
            message: failure.message,
          ));
        },
            (_) {
          print("MarkTaken successful");
          // Update local taken map - THIS IS THE KEY CHANGE
          final updatedTakenMap = Map<String, bool>.from(state.takenMap);
          updatedTakenMap[event.medicineId] = event.taken;

          emit(_createUpdatedState(
            state.medicines, // Keep original medicines
            takenMap: updatedTakenMap,
            optimisticTaken: {}, // Clear optimistic state
          ));

          // Show success message
          emit(MedicineActionSuccess(
            medicines: state.medicines,
            takenMap: updatedTakenMap,
            optimisticTaken: {},
            message: event.taken ? 'Marked as taken' : 'Marked as skipped',
          ));
        },
      );
    } catch (e, stack) {
      print("MarkTaken error: $e\n$stack");
      emit(MedicineError(
        medicines: state.medicines,
        takenMap: state.takenMap,
        optimisticTaken: state.optimisticTaken,
        message: 'Failed to update taken status: $e',
      ));
    }
  }

  void _onUpdateOptimistic(
      UpdateTakenStatusOptimistic event,
      Emitter<MedicineState> emit,
      ) {
    final updatedOptimistic = Map<String, bool>.from(state.optimisticTaken);
    updatedOptimistic[event.medicineId] = event.taken;

    emit(_createUpdatedState(
      state.medicines,
      optimisticTaken: updatedOptimistic,
    ));
  }

  void _onClearError(ClearError event, Emitter<MedicineState> emit) {
    if (state is MedicineError) {
      emit(MedicineInitial());
    }
  }

  MedicineState _createUpdatedState(
      List<MedicineReminder> medicines, {
        Map<String, bool>? takenMap,
        Map<String, bool>? optimisticTaken,
      }) {
    final effectiveTakenMap = takenMap ?? state.takenMap;
    final effectiveOptimistic = optimisticTaken ?? state.optimisticTaken;

    if (state is TodaysMedicinesLoaded) {
      return TodaysMedicinesLoaded(
        medicines: medicines,
        takenMap: effectiveTakenMap,
        optimisticTaken: effectiveOptimistic,
      );
    } else if (state is AllMedicinesLoaded) {
      return AllMedicinesLoaded(
        medicines: medicines,
        takenMap: effectiveTakenMap,
        optimisticTaken: effectiveOptimistic,
      );
    } else if (state is MedicineLoading) {
      return MedicineLoading(
        medicines: medicines,
        takenMap: effectiveTakenMap,
        optimisticTaken: effectiveOptimistic,
        isFullList: (state as MedicineLoading).isFullList,
      );
    } else if (state is MedicineActionSuccess) {
      return MedicineActionSuccess(
        medicines: medicines,
        takenMap: effectiveTakenMap,
        optimisticTaken: effectiveOptimistic,
        message: (state as MedicineActionSuccess).message,
      );
    } else if (state is MedicineError) {
      return MedicineError(
        medicines: medicines,
        takenMap: effectiveTakenMap,
        optimisticTaken: effectiveOptimistic,
        message: (state as MedicineError).message,
      );
    }

    return TodaysMedicinesLoaded(
      medicines: medicines,
      takenMap: effectiveTakenMap,
      optimisticTaken: effectiveOptimistic,
    );
  }

  @override
  Future<void> close() {
    _medicinesSubscription?.cancel();
    return super.close();
  }
}