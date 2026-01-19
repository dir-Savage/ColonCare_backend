import 'package:equatable/equatable.dart';
import '../../domain/entities/medicine_reminder.dart';

sealed class MedicineState extends Equatable {
  final List<MedicineReminder> medicines;
  final Map<String, bool> takenMap;
  final Map<String, bool> optimisticTaken;

  const MedicineState({
    this.medicines = const [],
    this.takenMap = const {},
    this.optimisticTaken = const {},
  });

  bool getMedicineTakenStatus(String medicineId) {
    if (optimisticTaken.containsKey(medicineId)) {
      return optimisticTaken[medicineId]!;
    }
    return takenMap[medicineId] ?? false;
  }

  List<MedicineReminder> getActiveMedicines() {
    return medicines.where((m) => m.isActive).toList();
  }

  @override
  List<Object?> get props => [medicines, takenMap, optimisticTaken];
}

class MedicineInitial extends MedicineState {
  const MedicineInitial();
}

class MedicineLoading extends MedicineState {
  final bool isFullList;
  const MedicineLoading({
    super.medicines,
    super.takenMap,
    super.optimisticTaken,
    this.isFullList = false,
  });

  @override
  List<Object?> get props => [...super.props, isFullList];
}

class TodaysMedicinesLoaded extends MedicineState {
  const TodaysMedicinesLoaded({
    required super.medicines,
    required super.takenMap,
    super.optimisticTaken = const {},
  });
}

class AllMedicinesLoaded extends MedicineState {
  const AllMedicinesLoaded({
    required super.medicines,
    super.takenMap = const {},
    super.optimisticTaken = const {},
  });
}

class MedicineActionSuccess extends MedicineState {
  final String message;
  const MedicineActionSuccess({
    required super.medicines,
    required super.takenMap,
    super.optimisticTaken = const {},
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

class MedicineError extends MedicineState {
  final String message;
  const MedicineError({
    super.medicines = const [],
    super.takenMap = const {},
    super.optimisticTaken = const {},
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}