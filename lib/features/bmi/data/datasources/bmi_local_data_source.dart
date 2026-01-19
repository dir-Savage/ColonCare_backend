import 'dart:convert';
import 'package:coloncare/features/bmi/domain/entities/bmi_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BmiLocalDataSource {
  Future<void> saveBmiRecord(BmiRecord record);
  Future<List<BmiRecord>> getBmiHistory();
  Future<void> deleteBmiRecord(String id);
  Future<void> clearBmiHistory();
}

class BmiLocalDataSourceImpl implements BmiLocalDataSource {
  static const String _bmiRecordsKey = 'bmi_records';

  @override
  Future<void> saveBmiRecord(BmiRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getBmiHistory();

    // Add new record at the beginning (newest first)
    records.insert(0, record);

    // Save updated list
    final recordsJson = records.map((r) => _recordToJson(r)).toList();
    await prefs.setString(_bmiRecordsKey, jsonEncode(recordsJson));
  }

  @override
  Future<List<BmiRecord>> getBmiHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString(_bmiRecordsKey);

    if (recordsJson == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(recordsJson);
      return jsonList.map((json) => _recordFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> deleteBmiRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getBmiHistory();

    final updatedRecords = records.where((record) => record.id != id).toList();

    final recordsJson = updatedRecords.map((r) => _recordToJson(r)).toList();
    await prefs.setString(_bmiRecordsKey, jsonEncode(recordsJson));
  }

  @override
  Future<void> clearBmiHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bmiRecordsKey);
  }

  Map<String, dynamic> _recordToJson(BmiRecord record) {
    return {
      'id': record.id,
      'weight': record.weight,
      'height': record.height,
      'bmi': record.bmi,
      'category': record.category,
      'date': record.date.toIso8601String(),
      'notes': record.notes,
    };
  }

  BmiRecord _recordFromJson(Map<String, dynamic> json) {
    return BmiRecord(
      id: json['id'] as String,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }
}