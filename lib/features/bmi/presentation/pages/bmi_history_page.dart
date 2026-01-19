import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/features/bmi/domain/entities/bmi_record.dart';
import 'package:coloncare/features/bmi/presentation/blocs/bmi_bloc.dart';
import 'package:coloncare/features/bmi/presentation/blocs/bmi_event.dart';
import 'package:coloncare/features/bmi/presentation/blocs/bmi_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injector.dart';

class BmiHistoryPage extends StatelessWidget {
  const BmiHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BmiBloc>(
      create: (_) => getIt<BmiBloc>()..add(const BmiHistoryRequested()),
      child: const _BmiHistoryPageContent(),
    );
  }
}

class _BmiHistoryPageContent extends StatelessWidget {
  const _BmiHistoryPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI History'),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Image(
            image: const AssetImage(AssetsManager.appLogo),
            fit: BoxFit.contain,
            height: 50,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
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
        ],
      ),
      body: BlocBuilder<BmiBloc, BmiState>(
        builder: (context, state) {
          if (state is BmiHistoryLoading) {
            return _buildLoadingState();
          }

          if (state is BmiHistoryError) {
            return _buildErrorState(context, state.message);
          }

          if (state is BmiHistoryLoaded) {
            if (state.records.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildHistoryList(context, state.records);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading history...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<BmiBloc>().add(const BmiHistoryRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assessment_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No BMI records yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Calculate your first BMI to see it here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Calculate BMI'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<BmiRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildHistoryItem(context, record, index);
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, BmiRecord record, int index) {
    Color getBmiColor(double bmi) {
      if (bmi < 18.5) return Colors.orange;
      if (bmi < 25) return Colors.green;
      if (bmi < 30) return Colors.orange;
      return Colors.red;
    }

    final bmiColor = getBmiColor(record.bmi);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: bmiColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: bmiColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  record.bmi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: bmiColor,
                  ),
                ),
                Text(
                  'BMI',
                  style: TextStyle(
                    fontSize: 10,
                    color: bmiColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          record.category,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: bmiColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${record.weight.toStringAsFixed(1)} kg / ${record.height.toStringAsFixed(1)} cm',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${record.formattedDate} at ${record.formattedTime}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.grey,
          ),
          onPressed: () {
            _showDeleteDialog(context, record.id);
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete BMI Record'),
        content: const Text('Are you sure you want to delete this BMI record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BmiBloc>().add(BmiRecordDeleted(recordId));
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('BMI record deleted'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}