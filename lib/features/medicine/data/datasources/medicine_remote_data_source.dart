import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/medicine_reminder.dart';
import '../models/medicine_reminder_model.dart';
import '../models/taken_status_model.dart';

abstract interface class MedicineRemoteDataSource {
  Future<MedicineReminder> saveMedicine(MedicineReminder reminder);
  Stream<List<MedicineReminder>> watchAllMedicines(String userId);
  Future<List<MedicineReminder>> getAllMedicines(String userId);
  Future<List<MedicineReminder>> getMedicinesForDay(String userId, DateTime day);
  Future<void> recordTakenStatus(TakenStatus status);
  Future<List<TakenStatus>> getTakenStatusForDay(String userId, DateTime day);
  Future<void> deleteMedicine(String medicineId);
  Future<void> setActiveStatus(String medicineId, {required bool active});
  Future<void> updateLastTaken({
    required String medicineId,
    required DateTime takenAt,
    required bool isFirstDoseOfDay,
  });
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MedicineRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
        _auth = auth;

  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw Exception('User is not authenticated');
    }
    return user.uid;
  }

  @override
  Future<MedicineReminder> saveMedicine(MedicineReminder reminder) async {
    print("🔥 saveMedicine called: ${reminder.title}, id: ${reminder.id}");
    final userId = _getCurrentUserId();
    final model = MedicineReminderModel(
      id: reminder.id.isEmpty
          ? _firestore.collection('medicine_reminders').doc().id
          : reminder.id,
      userId: userId,
      title: reminder.title,
      purpose: reminder.purpose,
      startDate: reminder.startDate,
      endDate: reminder.endDate,
      daysOfWeek: reminder.daysOfWeek,
      isActive: reminder.isActive,
      createdAt: reminder.createdAt,
      updatedAt: DateTime.now(),
      hourInterval: reminder.hourInterval,
      firstDoseTimeOfDay: reminder.firstDoseTimeOfDay,
      lastTakenDateTime: reminder.lastTakenDateTime,
    );

    print("📝 Model created: ${model.toFirestore()}");

    final ref = _firestore.collection('medicine_reminders').doc(model.id);
    await ref.set(model.toFirestore(), SetOptions(merge: true));

    print("✅ Medicine saved to Firestore with ID: ${model.id}");
    return model;
  }

  @override
  Stream<List<MedicineReminder>> watchAllMedicines(String userId) {
    return _firestore
        .collection('medicine_reminders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MedicineReminderModel.fromFirestore(doc))
        .toList());
  }

  @override
  Future<List<MedicineReminder>> getAllMedicines(String userId) async {
    final snapshot = await _firestore
        .collection('medicine_reminders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => MedicineReminderModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<MedicineReminder>> getMedicinesForDay(
      String userId,
      DateTime day,
      ) async {
    print("📅 getMedicinesForDay called: userId=$userId, day=$day");

    final all = await getAllMedicines(userId);
    final normalized = DateTime(day.year, day.month, day.day);

    print("📊 Total medicines: ${all.length}");

    final filtered = all.where((reminder) {
      final isScheduled = reminder.isScheduledOn(normalized);
      print("  - ${reminder.title}: isScheduled=$isScheduled");
      return isScheduled;
    }).toList();

    print("✅ Medicines for day: ${filtered.length}");
    return filtered;
  }

  @override
  Future<void> recordTakenStatus(TakenStatus status) async {
    final userId = _getCurrentUserId();
    final dateStr = status.date.toIso8601String().split('T').first;
    final docId = '${status.medicineId}_$dateStr';

    final model = TakenStatusModel(
      medicineId: status.medicineId,
      date: status.date,
      taken: status.taken,
      takenAt: status.takenAt,
      isFirstDoseOfTheDay: status.isFirstDoseOfTheDay,
    );

    await _firestore
        .collection('medicine_taken_status')
        .doc(docId)
        .set({
      ...model.toFirestore(),
      'userId': userId,
    }, SetOptions(merge: true));
  }

  @override
  Future<List<TakenStatus>> getTakenStatusForDay(
      String userId,
      DateTime day,
      ) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('medicine_taken_status')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    return snapshot.docs
        .map((doc) => TakenStatusModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> deleteMedicine(String medicineId) async {
    final userId = _getCurrentUserId();
    final ref = _firestore.collection('medicine_reminders').doc(medicineId);
    final doc = await ref.get();

    if (!doc.exists) {
      throw Exception('Medicine not found');
    }
    if (doc.data()?['userId'] != userId) {
      throw Exception('Permission denied');
    }

    await ref.delete();
  }

  @override
  Future<void> setActiveStatus(String medicineId, {required bool active}) async {
    final userId = _getCurrentUserId();
    await _firestore.collection('medicine_reminders').doc(medicineId).update({
      'isActive': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateLastTaken({
    required String medicineId,
    required DateTime takenAt,
    required bool isFirstDoseOfDay,
  }) async {
    final updates = {
      'lastTakenDateTime': Timestamp.fromDate(takenAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isFirstDoseOfDay) {
      updates['firstDoseTimeOfDay'] = {
        'hour': takenAt.hour,
        'minute': takenAt.minute,
      };
    }

    await _firestore.collection('medicine_reminders').doc(medicineId).update(updates);
  }
}