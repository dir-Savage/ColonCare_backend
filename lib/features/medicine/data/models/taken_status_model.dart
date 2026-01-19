import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medicine_reminder.dart';

class TakenStatusModel extends TakenStatus {
  const TakenStatusModel({
    required super.medicineId,
    required super.date,
    super.taken = false,
    super.takenAt,
    super.isFirstDoseOfTheDay = false,
  });

  factory TakenStatusModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return TakenStatusModel(
      medicineId: data['medicineId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      taken: data['taken'] as bool? ?? false,
      takenAt: (data['takenAt'] as Timestamp?)?.toDate(),
      isFirstDoseOfTheDay: data['isFirstDoseOfTheDay'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicineId': medicineId,
      'date': Timestamp.fromDate(date),
      'taken': taken,
      if (takenAt != null) 'takenAt': Timestamp.fromDate(takenAt!),
      'isFirstDoseOfTheDay': isFirstDoseOfTheDay,
    };
  }
}