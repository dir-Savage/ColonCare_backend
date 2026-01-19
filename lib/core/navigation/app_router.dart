// lib/core/navigation/app_router.dart
import 'package:coloncare/features/auth/presentation/pages/login_page.dart';
import 'package:coloncare/features/auth/presentation/pages/register_page.dart';
import 'package:coloncare/features/auth/presentation/pages/reset_password_page.dart';
import 'package:coloncare/features/chatbot/presentation/pages/chatbot_page.dart';
import 'package:coloncare/features/home/presentation/pages/home_page.dart';
import 'package:coloncare/features/home/presentation/pages/navbar.dart';
import 'package:coloncare/features/medicine/presentation/pages/add_edit_medicine_page.dart';
import 'package:coloncare/features/medicine/presentation/pages/all_medicines_page.dart';
import 'package:coloncare/features/medicine/presentation/pages/medicine_today_page.dart';
import 'package:coloncare/features/medicine/presentation/pages/statistics_page.dart';
import 'package:coloncare/features/predict/presentation/pages/prediction_history_page.dart';
import 'package:coloncare/features/predict/presentation/pages/prediction_page.dart';
import 'package:coloncare/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';

import '../../features/bmi/presentation/pages/bmi_calculator_page.dart';
import '../../features/bmi/presentation/pages/bmi_history_page.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String navbar = '/navbar';
  static const String prediction = '/prediction';
  static const String predictionHistory = '/prediction-history';
  static const String chatbot = '/chatbot';
  static const String bmiCalculator = '/bmi-calculator';
  static const String bmiHistory = '/bmi-history';
  static const String medicineToday = '/medicine-today';
  static const String medicineAll = '/medicine-all';
  static const String addEditMedicine = '/medicine-add-edit';
  static const String medicineStats = '/medicine-stats';


  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    //  final args = settings.arguments;

    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashPage(), settings);
      case login:
        return _buildRoute(const LoginPage(), settings);
      case register:
        return _buildRoute(const RegisterPage(), settings);
      case resetPassword:
        return _buildRoute(const ResetPasswordPage(), settings);
      case home:
        return _buildRoute(const HomePage(), settings);
      case navbar:
        return _buildRoute(MainNavigation(), settings);
      case prediction:
        return _buildRoute(const PredictionPage(), settings);
      case predictionHistory:
        return _buildRoute(const PredictionHistoryPage(), settings);
      case chatbot:
        return _buildRoute(const ChatbotPage(), settings);
      case bmiCalculator:
        return _buildRoute(const BmiCalculatorPage(), settings);
      case bmiHistory:
        return _buildRoute(const BmiHistoryPage(), settings);
      case medicineToday:
        return _buildRoute(const MedicineTodayPage(), settings);
      case medicineAll:
        return _buildRoute(const AllMedicinesPage(), settings);
      case addEditMedicine:
        return _buildRoute(const AddEditMedicinePage(), settings);
      case medicineStats:
        return _buildRoute(const MedicineStatisticsPage(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text(
                'Route not found: ${settings.name}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          settings,
        );
    }
  }

  // Helper method for building routes
  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  // Navigation helpers (convenience methods)
  static Future<dynamic> pushNamed(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> pushReplacementNamed(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.of(context).pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic> pushNamedAndRemoveUntil(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }
}