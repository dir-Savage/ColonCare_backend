import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class HealthCheckSettings extends Equatable {
  final Duration checkInterval;
  final bool isEnabled;
  final bool showOnAppStart;
  final bool showDailyReminder;
  final TimeOfDay? dailyReminderTime;

  const HealthCheckSettings({
    this.checkInterval = const Duration(hours: 10),
    this.isEnabled = true,
    this.showOnAppStart = true,
    this.showDailyReminder = false,
    this.dailyReminderTime,
  });

  factory HealthCheckSettings.defaultSettings() {
    return const HealthCheckSettings(
      checkInterval: Duration(hours: 10),
      isEnabled: true,
      showOnAppStart: true,
      showDailyReminder: false,
    );
  }

  HealthCheckSettings copyWith({
    Duration? checkInterval,
    bool? isEnabled,
    bool? showOnAppStart,
    bool? showDailyReminder,
    TimeOfDay? dailyReminderTime,
  }) {
    return HealthCheckSettings(
      checkInterval: checkInterval ?? this.checkInterval,
      isEnabled: isEnabled ?? this.isEnabled,
      showOnAppStart: showOnAppStart ?? this.showOnAppStart,
      showDailyReminder: showDailyReminder ?? this.showDailyReminder,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkInterval': checkInterval.inHours,
      'isEnabled': isEnabled,
      'showOnAppStart': showOnAppStart,
      'showDailyReminder': showDailyReminder,
      'dailyReminderTime': dailyReminderTime != null
          ? '${dailyReminderTime!.hour}:${dailyReminderTime!.minute}'
          : null,
    };
  }

  factory HealthCheckSettings.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return HealthCheckSettings(
      checkInterval: Duration(hours: json['checkInterval'] as int? ?? 10),
      isEnabled: json['isEnabled'] as bool? ?? true,
      showOnAppStart: json['showOnAppStart'] as bool? ?? true,
      showDailyReminder: json['showDailyReminder'] as bool? ?? false,
      dailyReminderTime: parseTime(json['dailyReminderTime'] as String?),
    );
  }

  @override
  List<Object?> get props => [
    checkInterval,
    isEnabled,
    showOnAppStart,
    showDailyReminder,
    dailyReminderTime,
  ];
}