import 'package:coloncare/features/health_check/domain/repositories/health_check_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_settings.dart';
import 'package:coloncare/features/health_check/domain/usecases/get_health_check_settings_usecase.dart';
import 'package:coloncare/features/health_check/domain/usecases/update_health_check_settings_usecase.dart';
import '../../../../core/di/injector.dart';

class HealthCheckSettingsWidget extends StatefulWidget {
  const HealthCheckSettingsWidget({super.key});

  @override
  State<HealthCheckSettingsWidget> createState() => _HealthCheckSettingsWidgetState();
}

class _HealthCheckSettingsWidgetState extends State<HealthCheckSettingsWidget> {
  late HealthCheckSettings _settings;
  late GetHealthCheckSettingsUseCase _getSettingsUseCase;
  late UpdateHealthCheckSettingsUseCase _updateSettingsUseCase;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getSettingsUseCase = getIt<GetHealthCheckSettingsUseCase>();
    _updateSettingsUseCase = getIt<UpdateHealthCheckSettingsUseCase>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    _settings = await _getSettingsUseCase();
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    final result = await _updateSettingsUseCase(_settings);
    setState(() => _isLoading = false);

    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
          (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  void _updateInterval(int hours) {
    setState(() {
      _settings = _settings.copyWith(
        checkInterval: Duration(hours: hours),
      );
    });
    _saveSettings();
  }

  void _toggleEnabled(bool value) {
    setState(() {
      _settings = _settings.copyWith(isEnabled: value);
    });
    _saveSettings();
  }

  void _toggleShowOnAppStart(bool value) {
    setState(() {
      _settings = _settings.copyWith(showOnAppStart: value);
    });
    _saveSettings();
  }

  void _toggleDailyReminder(bool value) {
    setState(() {
      _settings = _settings.copyWith(showDailyReminder: value);
    });
    _saveSettings();
  }

  Future<void> _selectDailyReminderTime() async {
    final initialTime = _settings.dailyReminderTime ?? const TimeOfDay(hour: 9, minute: 0);

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      setState(() {
        _settings = _settings.copyWith(dailyReminderTime: selectedTime);
      });
      _saveSettings();
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    if (hours == 1) return 'Every hour';
    if (hours == 24) return 'Every day';
    return 'Every $hours hours';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.blue.shade600),
              const SizedBox(width: 10),
              const Text(
                'Health Check Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Enable/Disable Toggle
          _buildSettingRow(
            icon: Icons.toggle_on,
            title: 'Enable Health Checks',
            subtitle: 'Receive periodic health check questions',
            trailing: Switch(
              value: _settings.isEnabled,
              onChanged: _toggleEnabled,
              activeColor: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // Only show other settings if enabled
          if (_settings.isEnabled) ...[
            // Check Interval
            _buildSettingRow(
              icon: Icons.timer,
              title: 'Check Frequency',
              subtitle: _formatDuration(_settings.checkInterval),
              trailing: PopupMenuButton<int>(
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: _updateInterval,
                itemBuilder: (context) => [
                  PopupMenuItem(value: 1, child: Text(_formatDuration(const Duration(hours: 1)))),
                  PopupMenuItem(value: 2, child: Text(_formatDuration(const Duration(hours: 2)))),
                  PopupMenuItem(value: 4, child: Text(_formatDuration(const Duration(hours: 4)))),
                  PopupMenuItem(value: 6, child: Text(_formatDuration(const Duration(hours: 6)))),
                  PopupMenuItem(value: 8, child: Text(_formatDuration(const Duration(hours: 8)))),
                  PopupMenuItem(value: 12, child: Text(_formatDuration(const Duration(hours: 12)))),
                  PopupMenuItem(value: 24, child: Text(_formatDuration(const Duration(hours: 24)))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Show on App Start
            _buildSettingRow(
              icon: Icons.notifications,
              title: 'Show on App Start',
              subtitle: 'Show questions when opening the app',
              trailing: Switch(
                value: _settings.showOnAppStart,
                onChanged: _toggleShowOnAppStart,
                activeColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            // Daily Reminder
            _buildSettingRow(
              icon: Icons.alarm,
              title: 'Daily Reminder',
              subtitle: _settings.showDailyReminder && _settings.dailyReminderTime != null
                  ? 'Daily at ${_settings.dailyReminderTime!.format(context)}'
                  : 'Set a daily reminder time',
              trailing: Switch(
                value: _settings.showDailyReminder,
                onChanged: _toggleDailyReminder,
                activeColor: Colors.blue,
              ),
            ),
            if (_settings.showDailyReminder) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _selectDailyReminderTime,
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(
                  _settings.dailyReminderTime != null
                      ? 'Change time (${_settings.dailyReminderTime!.format(context)})'
                      : 'Set reminder time',
                  style: const TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade800,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Next Check Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next health check:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FutureBuilder<Duration>(
                          future: getIt<HealthCheckRepository>().getTimeUntilNextCheck(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final duration = snapshot.data!;
                              if (duration.inSeconds <= 0) {
                                return const Text(
                                  'Ready now',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                );
                              }
                              return Text(
                                'In ${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              );
                            }
                            return const Text('Calculating...');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Settings?'),
                  content: const Text('Reset all health check settings to defaults?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                setState(() {
                  _settings = HealthCheckSettings.defaultSettings();
                });
                _saveSettings();
              }
            },
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('Reset to Defaults'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}