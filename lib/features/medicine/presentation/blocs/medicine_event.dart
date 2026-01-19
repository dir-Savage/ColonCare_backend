import 'package:equatable/equatable.dart';

sealed class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodaysMedicines extends MedicineEvent {
  const LoadTodaysMedicines();
}

class LoadAllMedicines extends MedicineEvent {
  const LoadAllMedicines();
}

class WatchAllMedicines extends MedicineEvent {
  const WatchAllMedicines();
}

class SaveMedicineEvent extends MedicineEvent {
  final String title;
  final String purpose;
  final DateTime startDate;
  final DateTime? endDate;
  final int hourInterval;
  final List<String> daysOfWeek;
  final String? medicineId;

  const SaveMedicineEvent({
    required this.title,
    required this.purpose,
    required this.startDate,
    this.endDate,
    required this.hourInterval,
    this.daysOfWeek = const [],
    this.medicineId,
  });

  @override
  List<Object?> get props => [
    title,
    purpose,
    startDate,
    endDate,
    hourInterval,
    daysOfWeek,
    medicineId,
  ];
}

class DeleteMedicineEvent extends MedicineEvent {
  final String medicineId;
  const DeleteMedicineEvent(this.medicineId);

  @override
  List<Object> get props => [medicineId];
}

class ToggleActiveEvent extends MedicineEvent {
  final String medicineId;
  final bool active;
  const ToggleActiveEvent({
    required this.medicineId,
    required this.active,
  });

  @override
  List<Object> get props => [medicineId, active];
}

class MarkTakenEvent extends MedicineEvent {
  final String medicineId;
  final bool taken;
  final bool isFirstDoseOfDay;
  const MarkTakenEvent({
    required this.medicineId,
    this.taken = true,
    this.isFirstDoseOfDay = false,
  });

  @override
  List<Object> get props => [medicineId, taken, isFirstDoseOfDay];
}

class UpdateTakenStatusOptimistic extends MedicineEvent {
  final String medicineId;
  final bool taken;

  const UpdateTakenStatusOptimistic({
    required this.medicineId,
    required this.taken,
  });

  @override
  List<Object> get props => [medicineId, taken];
}

class ClearError extends MedicineEvent {
  const ClearError();
}