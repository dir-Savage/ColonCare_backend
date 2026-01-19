// import 'package:coloncare/core/utils/notification_integrator.dart';
// import 'package:flutter/material.dart';
//
// class NotificationPermissionDialog {
//   static Future<bool> showIfNeeded(BuildContext context) async {
//     final integrator = MedicineNotificationIntegrator();
//
//     if (await integrator.checkNotificationPermissions()) return true;
//
//     return await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text('تفعيل التذكيرات'),
//         content: const Text(
//           'يلزم السماح بالإشعارات والمنبهات الدقيقة لضمان وصول تذكير الدواء في موعده.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('لاحقًا'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await integrator.requestNotificationPermissions();
//               Navigator.pop(
//                 context,
//                 await integrator.checkNotificationPermissions(),
//               );
//             },
//             child: const Text('تفعيل'),
//           ),
//         ],
//       ),
//     ) ??
//         false;
//   }
// }
