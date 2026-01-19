import 'package:coloncare/features/medicine/domain/entities/medicine_reminder.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_bloc.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_event.dart';
import 'package:coloncare/features/medicine/presentation/pages/add_edit_medicine_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/medicine_state.dart' show MedicineState, MedicineLoading, MedicineError, AllMedicinesLoaded, MedicineActionSuccess, TodaysMedicinesLoaded;

class AllMedicinesPage extends StatefulWidget {
  const AllMedicinesPage({super.key});

  @override
  State<AllMedicinesPage> createState() => _AllMedicinesPageState();
}

class _AllMedicinesPageState extends State<AllMedicinesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineBloc>().add(const LoadAllMedicines());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Medicines'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddEditMedicinePage(),
            fullscreenDialog: true,
          ),
        ).then((_) {
          if (mounted) {
            context.read<MedicineBloc>().add(const LoadAllMedicines());
          }
        }),
      ),
      body: BlocConsumer<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (state is MedicineError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is MedicineActionSuccess) {

          }
        },
        builder: (context, state) {
          if (state is MedicineLoading && state.isFullList) {
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
                    onPressed: () => context.read<MedicineBloc>().add(const LoadAllMedicines()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Handle AllMedicinesLoaded OR MedicineActionSuccess states
          List<MedicineReminder> medicines = [];

          if (state is AllMedicinesLoaded) {
            medicines = state.medicines;
          } else if (state is MedicineActionSuccess) {
            // Use medicines from success state too
            medicines = state.medicines;
          } else if (state is TodaysMedicinesLoaded) {
            // If somehow we're in this state, use those medicines
            medicines = state.medicines;
          } else if (state is MedicineLoading) {
            // If loading with existing medicines, show them
            medicines = state.medicines;
          }

          if (medicines.isEmpty && !(state is MedicineLoading)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.medication_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No medicines yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first medicine reminder',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Medicine'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditMedicinePage(),
                        fullscreenDialog: true,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final activeMeds = medicines.where((m) => m.isActive).toList();
          final pausedMeds = medicines.where((m) => !m.isActive).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MedicineBloc>().add(const LoadAllMedicines());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (activeMeds.isNotEmpty) ...[
                  _buildCategoryHeader('Active Medicines', activeMeds.length, Colors.blue),
                  ...activeMeds.map((med) => _MedicineListItem(medicine: med)).toList(),
                  const SizedBox(height: 24),
                ],
                if (pausedMeds.isNotEmpty) ...[
                  _buildCategoryHeader('Paused Medicines', pausedMeds.length, Colors.grey),
                  ...pausedMeds.map((med) => _MedicineListItem(medicine: med)).toList(),
                ],
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: color,
            margin: const EdgeInsets.only(right: 12),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineListItem extends StatelessWidget {
  final MedicineReminder medicine;

  const _MedicineListItem({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: medicine.isActive
              ? Colors.blue.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          child: Icon(
            medicine.isActive ? Icons.medication : Icons.medication_outlined,
            color: medicine.isActive ? Colors.blue : Colors.grey,
          ),
        ),
        title: Text(
          medicine.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: !medicine.isActive ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              medicine.purpose,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              medicine.isActive
                  ? 'Every ${medicine.hourInterval}h • Active'
                  : 'Every ${medicine.hourInterval}h • Paused',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                medicine.isActive ? Icons.pause : Icons.play_arrow,
                color: medicine.isActive ? Colors.orange : Colors.green,
                size: 22,
              ),
              onPressed: () {
                // Show immediate feedback
                context.read<MedicineBloc>().add(
                  ToggleActiveEvent(
                    medicineId: medicine.id,
                    active: !medicine.isActive,
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 22),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditMedicinePage(medicine: medicine),
                      fullscreenDialog: true,
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<MedicineBloc>().add(const LoadAllMedicines());
                    }
                  });
                } else if (value == 'delete') {
                  _showDeleteDialog(context, medicine.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditMedicinePage(medicine: medicine),
            fullscreenDialog: true,
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine?'),
        content: const Text('This will permanently remove this medicine reminder.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<MedicineBloc>().add(DeleteMedicineEvent(id));
    }
  }
}