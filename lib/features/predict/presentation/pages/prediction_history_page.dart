import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/features/predict/domain/entities/prediction_history_entry.dart';
import 'package:coloncare/features/predict/presentation/blocs/prediction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injector.dart';
import 'prediction_details_page.dart';

class PredictionHistoryPage extends StatelessWidget {
  const PredictionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PredictionBloc>(
      create: (_) => getIt<PredictionBloc>()..add(const LoadPredictionHistory()),
      child: Scaffold(
        appBar: AppBar(
            title: const Text('History'),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image(
                  image: const AssetImage(AssetsManager.appLogo),
                  fit: BoxFit.contain,
                  height: 50),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    child: ClipOval(
                      child: SvgPicture.network(
                        AssetsManager.avatarUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
        body: BlocBuilder<PredictionBloc, PredictionState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return _buildLoadingState();
            }
            if (state is HistoryError) {
              return _buildErrorState(context, state.message);
            }
            if (state is HistoryLoaded) {
              if (state.history.isEmpty) {
                return _buildEmptyState();
              }
              return _buildHistoryList(context, state.history);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child:
      Image(image: AssetImage(AssetsManager.appLogo), width: 150, height: 150),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
              image: AssetImage(AssetsManager.errorGif), width: 100, height: 100),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PredictionBloc>().add(const LoadPredictionHistory());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: const AssetImage(AssetsManager.emptyGif), width: 300, height: 300),
          const Text(
            'No predictions yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make your first prediction to see it here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
      BuildContext context, List<PredictionHistoryEntry> history) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return _buildHistoryItem(context, entry, index);
      },
    );
  }

  Widget _buildHistoryItem(
      BuildContext context, PredictionHistoryEntry entry, int index) {
    Color getStatusColor(String prediction) {
      switch (prediction.toLowerCase()) {
        case 'normal':
          return Colors.green;
        case 'polyp':
          return Colors.orange;
        case 'cancer':
          return Colors.red;
        default:
          return Colors.blue;
      }
    }

    final statusColor = getStatusColor(entry.result.prediction);
    final formattedDate = _formatDate(entry.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          final bloc = BlocProvider.of<PredictionBloc>(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: bloc,
                child: PredictionDetailsPage(
                  predictionEntry: entry,
                ),
              ),
            ),
          );
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              _getStatusIcon(entry.result.prediction),
              color: statusColor,
              size: 24,
            ),
          ),
        ),
        title: Text(
          entry.result.prediction,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(entry.result.probability * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show OOD warning if needed
            if (entry.result.isOutOfDistribution)
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 18,
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  IconData _getStatusIcon(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'normal':
        return Icons.check_circle;
      case 'polyp':
        return Icons.warning;
      case 'cancer':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}