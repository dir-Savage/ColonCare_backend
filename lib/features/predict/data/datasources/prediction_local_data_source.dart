// features/prediction/data/datasources/prediction_local_data_source.dart
import 'package:coloncare/features/predict/data/models/prediction_history_entry_model.dart';

abstract class PredictionLocalDataSource {
  Future<List<PredictionHistoryEntryModel>?> getCachedHistory();
  Future<void> cacheHistory(List<PredictionHistoryEntryModel> history);
}

class PredictionLocalDataSourceImpl implements PredictionLocalDataSource {
  // For now, we skip caching (can add Hive, shared_preferences later)
  @override
  Future<List<PredictionHistoryEntryModel>?> getCachedHistory() async {
    return null;
  }

  @override
  Future<void> cacheHistory(List<PredictionHistoryEntryModel> history) async {
    // No-op for now
  }
}