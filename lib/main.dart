import 'package:coloncare/core/navigation/navigation_service.dart';
import 'package:coloncare/core/themes/app_theme.dart';
import 'package:coloncare/features/home/presentation/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/di/app_bloc_providers.dart';
import 'core/di/injector.dart';
import 'core/navigation/app_router.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background/flutter_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await init();
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "App Running",
    notificationText: "Running in background",
    notificationImportance: AndroidNotificationImportance.high,
  );

  bool hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
  if (hasPermissions) {
    await FlutterBackground.enableBackgroundExecution();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBlocProviders(
      child: MaterialApp(
        title: 'Colon Care',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
        navigatorKey: NavigationService().navigatorKey,
      ),
    );
  }
}