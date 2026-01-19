import 'package:coloncare/features/medicine/domain/entities/medicine_reminder.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_bloc.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_event.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_state.dart';
import 'package:coloncare/features/medicine/presentation/widgets/medicine_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicineStatisticsPage extends StatefulWidget {
  const MedicineStatisticsPage({super.key});

  @override
  State<MedicineStatisticsPage> createState() => _MedicineStatisticsPageState();
}

class _MedicineStatisticsPageState extends State<MedicineStatisticsPage> {
  @override
  void initState() {
    super.initState();
    // Load data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineBloc>().add(const LoadTodaysMedicines());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Statistics'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          if (state is MedicineLoading && state.medicines.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MedicineError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MedicineBloc>().add(const LoadTodaysMedicines()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Get medicines and takenMap from any state that has them
          List<MedicineReminder> medicines = [];
          Map<String, bool> takenMap = {};

          if (state is TodaysMedicinesLoaded) {
            medicines = state.medicines;
            takenMap = state.takenMap;
          } else if (state is AllMedicinesLoaded) {
            medicines = state.medicines;
            takenMap = state.takenMap;
          } else if (state is MedicineActionSuccess) {
            medicines = state.medicines;
            takenMap = state.takenMap;
          } else if (state is MedicineLoading) {
            medicines = state.medicines;
            takenMap = state.takenMap;
          } else if (state is MedicineError) {
            medicines = state.medicines;
            takenMap = state.takenMap;
          }

          if (medicines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No statistics available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add some medicines to see statistics',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Medicine'),
                    onPressed: () => Navigator.pop(context), // Will go back to add medicine
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MedicineBloc>().add(const LoadTodaysMedicines());
            },
            child: MedicineDashboard(
              medicines: medicines,
              takenMap: takenMap,
            ),
          );
        },
      ),
    );
  }
}