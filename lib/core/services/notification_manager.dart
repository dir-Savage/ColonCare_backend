// import 'package:flutter/foundation.dart';
// import 'notification_service.dart';
//
// class NotificationManager {
//   static final NotificationManager _instance =
//   NotificationManager._internal();
//   factory NotificationManager() => _instance;
//   NotificationManager._internal();
//
//   bool _initialized = false;
//
//   Future<void> initialize() async {
//     if (_initialized) return;
//     await NotificationService().initialize();
//     _initialized = true;
//     debugPrint('🔔 Notifications initialized');
//   }
//
//   bool get isInitialized => _initialized;
// }
