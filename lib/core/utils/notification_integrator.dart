// import 'dart:math';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// import '../services/notification_service.dart';
// import '../../features/medicine/domain/entities/medicine_reminder.dart';
//
// class MedicineNotificationIntegrator {
//   static bool _tzInitialized = false;
//
//   final _service = NotificationService();
//   FlutterLocalNotificationsPlugin get _plugin => _service.plugin;
//
//   MedicineNotificationIntegrator() {
//     _initTimezone();
//   }
//
//   void _initTimezone() {
//     if (_tzInitialized) return;
//     tz.initializeTimeZones();
//     tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
//     _tzInitialized = true;
//   }
//
//   int _notificationId(String medicineId, int dayOffset, int doseIndex) {
//     final hash = medicineId.hashCode;
//     return (hash + dayOffset * 997 + doseIndex * 31).abs() % 10000000;
//   }
//
//   Future<bool> checkNotificationPermissions() async {
//     final hasNotif = await _service.hasNotificationPermission();
//     final hasExact = await _service.hasExactAlarmPermission();
//     return hasNotif && hasExact;
//   }
//
//   Future<void> requestNotificationPermissions() async {
//     await _service.requestNotificationPermission();
//
//     // Android 12+ exact alarm permission
//     final exactGranted = await _service.hasExactAlarmPermission();
//     if (!exactGranted) {
//       await _service.requestExactAlarmPermission();
//     }
//   }
//
//   Future<void> scheduleMedicineReminders(MedicineReminder reminder) async {
//     if (!reminder.isActive || reminder.firstDoseTimeOfDay == null) return;
//
//     final now = DateTime.now();
//     var startDate = reminder.startDate;
//
//     if (startDate.isBefore(now)) startDate = now;
//
//     final dosesPerDay = max(1, (24 / reminder.hourInterval).ceil());
//
//     // If exact alarms not granted -> schedule inexact
//     final exactAllowed = await _service.hasExactAlarmPermission();
//
//     for (int dayOffset = 0; dayOffset < 365; dayOffset++) {
//       final candidate = startDate.add(Duration(days: dayOffset));
//       if (!reminder.isScheduledOn(candidate)) continue;
//
//       var doseTime = DateTime(
//         candidate.year,
//         candidate.month,
//         candidate.day,
//         reminder.firstDoseTimeOfDay!.hour,
//         reminder.firstDoseTimeOfDay!.minute,
//       );
//
//       for (int dose = 0; dose < dosesPerDay; dose++) {
//         if (dose > 0) {
//           doseTime = doseTime.add(Duration(hours: reminder.hourInterval));
//         }
//
//         if (doseTime.isBefore(now)) continue;
//
//         final tzTime = tz.TZDateTime.from(doseTime, tz.local);
//
//         await _plugin.zonedSchedule(
//           _notificationId(reminder.id, dayOffset, dose),
//           'وقت الدواء 💊',
//           reminder.title,
//           tzTime,
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               NotificationService.medicineChannelId,
//               'Medicine Reminders',
//               importance: Importance.max,
//               priority: Priority.high,
//               playSound: true,
//               fullScreenIntent: true,
//             ),
//           ),
//           androidScheduleMode: exactAllowed
//               ? AndroidScheduleMode.exactAllowWhileIdle
//               : AndroidScheduleMode.inexactAllowWhileIdle,
//         );
//       }
//     }
//   }
//
//   Future<void> cancelMedicineReminders(String medicineId) async {
//     for (int day = 0; day < 400; day++) {
//       for (int dose = 0; dose < 12; dose++) {
//         await _plugin.cancel(_notificationId(medicineId, day, dose));
//       }
//     }
//   }
// }
