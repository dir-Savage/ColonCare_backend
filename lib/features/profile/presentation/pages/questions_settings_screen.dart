import 'package:coloncare/features/health_check/presentation/widgets/health_check_settings_widget.dart';
import 'package:flutter/material.dart';

class QuestionsSettingsScreen extends StatelessWidget {
  const QuestionsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions Settings'),
      ),
      body: const Center(
        child: HealthCheckSettingsWidget(),
      ),
    );
  }
}
