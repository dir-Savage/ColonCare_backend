// import 'dart:io';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class NotificationService {
//   NotificationService._();
//   static final NotificationService _instance = NotificationService._();
//   factory NotificationService() => _instance;
//
//   final FlutterLocalNotificationsPlugin _plugin =
//   FlutterLocalNotificationsPlugin();
//
//   static const String medicineChannelId = 'medicine_channel';
//
//   FlutterLocalNotificationsPlugin get plugin => _plugin;
//
//   Future<void> initialize() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const settings = InitializationSettings(android: androidInit);
//
//     await _plugin.initialize(settings);
//     await _createChannels();
//   }
//
//   Future<void> _createChannels() async {
//     const channel = AndroidNotificationChannel(
//       medicineChannelId,
//       'Medicine Reminders',
//       description: 'Scheduled medicine reminders',
//       importance: Importance.max,
//       playSound: true,
//     );
//
//     final android =
//     _plugin.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();
//
//     await android?.createNotificationChannel(channel);
//   }
//
//   // 🔥 Notification permission (Android 13+)
//   Future<bool> hasNotificationPermission() async {
//     if (!Platform.isAndroid) return true;
//     final status = await Permission.notification.status;
//     return status.isGranted;
//   }
//
//   Future<bool> requestNotificationPermission() async {
//     if (!Platform.isAndroid) return true;
//     final result = await Permission.notification.request();
//     return result.isGranted;
//   }
//
//   // 🔥 Exact alarm permission (Android 12+)
//   Future<bool> hasExactAlarmPermission() async {
//     if (!Platform.isAndroid) return true;
//     final status = await Permission.scheduleExactAlarm.status;
//     return status.isGranted;
//   }
//
//   Future<bool> requestExactAlarmPermission() async {
//     if (!Platform.isAndroid) return true;
//     final result = await Permission.scheduleExactAlarm.request();
//     return result.isGranted;
//   }
// }
