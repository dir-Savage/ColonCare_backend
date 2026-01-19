import 'dart:convert';
import 'package:coloncare/features/health_check/domain/entities/health_check_result.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class HealthCheckLocalDataSource {
  Future<void> saveLastCheckTime(DateTime time);
  Future<DateTime?> getLastCheckTime();
  Future<void> saveHealthCheckResult(HealthCheckResult result);
  Future<List<HealthCheckResult>> getHealthCheckHistory();
  Future<void> clearHistory();

  // NEW: Settings methods
  Future<void> saveHealthCheckSettings(HealthCheckSettings settings);
  Future<HealthCheckSettings> getHealthCheckSettings();
  Future<void> clearSettings();
}

class HealthCheckLocalDataSourceImpl implements HealthCheckLocalDataSource {
  static const String _lastCheckKey = 'health_check_last_time';
  static const String _historyKey = 'health_check_history';
  static const String _settingsKey = 'health_check_settings';

  @override
  Future<void> saveLastCheckTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCheckKey, time.toIso8601String());
  }

  @override
  Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_lastCheckKey);

    if (timeString == null) return null;

    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveHealthCheckResult(HealthCheckResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHealthCheckHistory();

    history.insert(0, result);
    final limitedHistory = history.take(30).toList();

    final historyJson = limitedHistory.map((r) => _resultToJson(r)).toList();
    await prefs.setString(_historyKey, jsonEncode(historyJson));
  }

  @override
  Future<List<HealthCheckResult>> getHealthCheckHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);

    if (historyJson == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(historyJson);
      return jsonList.map((json) => _resultFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastCheckKey);
    await prefs.remove(_historyKey);
  }

  // NEW: Settings methods
  @override
  Future<void> saveHealthCheckSettings(HealthCheckSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<HealthCheckSettings> getHealthCheckSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson == null) {
      return HealthCheckSettings.defaultSettings();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(settingsJson);
      return HealthCheckSettings.fromJson(json);
    } catch (e) {
      return HealthCheckSettings.defaultSettings();
    }
  }

  @override
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }

  Map<String, dynamic> _resultToJson(HealthCheckResult result) {
    return {
      'id': result.id,
      'answers': result.answers,
      'score': result.score,
      'riskLevel': result.riskLevel.index,
      'timestamp': result.timestamp.toIso8601String(),
    };
  }

  HealthCheckResult _resultFromJson(Map<String, dynamic> json) {
    return HealthCheckResult(
      id: json['id'] as String,
      answers: Map<String, String>.from(json['answers'] as Map),
      score: json['score'] as int,
      riskLevel: RiskLevel.values[json['riskLevel'] as int],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}