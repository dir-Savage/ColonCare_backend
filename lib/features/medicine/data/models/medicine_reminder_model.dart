import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/medicine_reminder.dart';

class MedicineReminderModel extends MedicineReminder {
  const MedicineReminderModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.purpose,
    required super.startDate,
    super.endDate,
    super.daysOfWeek = const [],
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
    required super.hourInterval,
    super.firstDoseTimeOfDay,
    super.lastTakenDateTime,
  });

  factory MedicineReminderModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    final firstDoseMap = data['firstDoseTimeOfDay'] as Map<String, dynamic>?;
    final lastTakenTs = data['lastTakenDateTime'] as Timestamp?;

    return MedicineReminderModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: (data['title'] as String? ?? '').trim(),
      purpose: (data['purpose'] as String? ?? '').trim(),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime(2000),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      daysOfWeek: List<String>.from(data['daysOfWeek'] ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime(2000),
      hourInterval: data['hourInterval'] as int? ?? 8,
      firstDoseTimeOfDay: firstDoseMap != null
          ? TimeOfDay(
        hour: (firstDoseMap['hour'] as num?)?.toInt() ?? 8,
        minute: (firstDoseMap['minute'] as num?)?.toInt() ?? 0,
      )
          : null,
      lastTakenDateTime: lastTakenTs?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title.trim(),
      'purpose': purpose.trim(),
      'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'hourInterval': hourInterval,
      if (firstDoseTimeOfDay != null)
        'firstDoseTimeOfDay': {
          'hour': firstDoseTimeOfDay!.hour,
          'minute': firstDoseTimeOfDay!.minute,
        },
      if (lastTakenDateTime != null)
        'lastTakenDateTime': Timestamp.fromDate(lastTakenDateTime!),
    };
  }
}