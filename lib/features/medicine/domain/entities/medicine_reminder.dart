import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MedicineReminder extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String purpose;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> daysOfWeek; // e.g. ["Mon", "Tue", "Wed"]
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  final int hourInterval;
  final TimeOfDay? firstDoseTimeOfDay;
  final DateTime? lastTakenDateTime;

  const MedicineReminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.purpose,
    required this.startDate,
    this.endDate,
    this.daysOfWeek = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.hourInterval,
    this.firstDoseTimeOfDay,
    this.lastTakenDateTime,
  });

  /// Whether this medicine is scheduled to be taken on the given date
  bool isScheduledOn(DateTime date) {
    print("🔍 Checking if medicine '$title' is scheduled on ${date.toIso8601String()}");
    print("  - isActive: $isActive");
    print("  - startDate: ${startDate.toIso8601String()}");
    print("  - endDate: ${endDate?.toIso8601String()}");
    print("  - daysOfWeek: $daysOfWeek");

    if (!isActive) {
      print("  ❌ Not active");
      return false;
    }

    // Normalize dates to compare only dates (not times)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);

    if (normalizedDate.isBefore(normalizedStart)) {
      print("  ❌ Date is before start date");
      return false;
    }

    if (endDate != null) {
      final normalizedEnd = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (normalizedDate.isAfter(normalizedEnd)) {
        print("  ❌ Date is after end date");
        return false;
      }
    }

    // If specific days are selected → must match
    if (daysOfWeek.isNotEmpty) {
      final weekdayName = _weekdayToShortName(date.weekday);
      final isScheduled = daysOfWeek.contains(weekdayName);
      print("  📅 Checking weekday: $weekdayName, contains: $isScheduled");
      return isScheduled;
    }

    // Otherwise: every day
    print("  ✅ Scheduled (every day)");
    return true;
  }

  /// Whether the next dose is now or overdue
  bool isDueNow({DateTime? currentTime}) {
    if (!isActive) return false;

    final now = currentTime ?? DateTime.now();
    final nextDose = getNextDoseTime();
    if (nextDose == null) return false;

    return nextDose.isBefore(now) || nextDose.isAtSameMomentAs(now);
  }

  /// Calculates when the next dose should be taken
  DateTime? getNextDoseTime({DateTime? fromTime}) {
    if (lastTakenDateTime == null || hourInterval <= 0) {
      return null;
    }

    final base = fromTime ?? DateTime.now();
    return lastTakenDateTime!.add(Duration(hours: hourInterval));
  }

  /// Time remaining until next dose (or negative if overdue)
  Duration? getTimeUntilNextDose() {
    final next = getNextDoseTime();
    if (next == null) return null;
    return next.difference(DateTime.now());
  }

  String getFormattedTimeUntilNext() {
    final duration = getTimeUntilNextDose();
    if (duration == null) return 'Not scheduled';
    if (duration.isNegative) return 'Overdue';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  String getCategory() {
    if (!isActive) return 'Paused';
    if (isDueNow()) return 'Due Now';

    final timeUntil = getTimeUntilNextDose();
    if (timeUntil != null && timeUntil.inHours < 2) {
      return 'Upcoming';
    }

    return 'Scheduled';
  }

  MedicineReminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? purpose,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? daysOfWeek,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? hourInterval,
    TimeOfDay? firstDoseTimeOfDay,
    DateTime? lastTakenDateTime,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hourInterval: hourInterval ?? this.hourInterval,
      firstDoseTimeOfDay: firstDoseTimeOfDay ?? this.firstDoseTimeOfDay,
      lastTakenDateTime: lastTakenDateTime ?? this.lastTakenDateTime,
    );
  }

  static String _weekdayToShortName(int weekday) {
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'purpose': purpose,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'hourInterval': hourInterval,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    purpose,
    startDate,
    endDate,
    daysOfWeek,
    isActive,
    createdAt,
    updatedAt,
    hourInterval,
    firstDoseTimeOfDay,
    lastTakenDateTime,
  ];
}

class TakenStatus extends Equatable {
  final String medicineId;
  final DateTime date;
  final bool taken;
  final DateTime? takenAt;
  final bool isFirstDoseOfTheDay;

  const TakenStatus({
    required this.medicineId,
    required this.date,
    this.taken = false,
    this.takenAt,
    this.isFirstDoseOfTheDay = false,
  });

  TakenStatus copyWith({
    String? medicineId,
    DateTime? date,
    bool? taken,
    DateTime? takenAt,
    bool? isFirstDoseOfTheDay,
  }) {
    return TakenStatus(
      medicineId: medicineId ?? this.medicineId,
      date: date ?? this.date,
      taken: taken ?? this.taken,
      takenAt: takenAt ?? this.takenAt,
      isFirstDoseOfTheDay: isFirstDoseOfTheDay ?? this.isFirstDoseOfTheDay,
    );
  }

  @override
  List<Object?> get props => [medicineId, date, taken, takenAt, isFirstDoseOfTheDay];
}