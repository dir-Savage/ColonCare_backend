import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/core/widgets/loading_indicator.dart';
import 'package:coloncare/features/medicine/domain/entities/medicine_reminder.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_bloc.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_event.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_state.dart';
import 'package:coloncare/features/medicine/presentation/pages/add_edit_medicine_page.dart';
import 'package:coloncare/features/medicine/presentation/pages/statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injector.dart';

class MedicineTodayPage extends StatefulWidget {
  const MedicineTodayPage({super.key});

  @override
  State<MedicineTodayPage> createState() => _MedicineTodayPageState();
}

class _MedicineTodayPageState extends State<MedicineTodayPage> {
  Timer? _refreshTimer;
  final Map<String, bool> _optimisticTaken = {};

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MedicineBloc>(
      create: (_) => getIt<MedicineBloc>()..add(const LoadTodaysMedicines()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          // leading: IconButton(
          //   onPressed: () => Navigator.pop(context),
          //   icon: Icon(Icons.arrow_back_ios),
          // ),
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "Today's Medicines",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt_rounded),
              onPressed: () => Navigator.pushNamed(context, '/medicine-all'),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 20,
                child: ClipOval(
                  child: SvgPicture.network(
                    AssetsManager.avatarUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocConsumer<MedicineBloc, MedicineState>(
          listener: (context, state) {
            if (state is MedicineError) {
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'On Snap!',
                  message:
                  'There was an error: ${state.message}',
                  contentType: ContentType.failure,
                  inMaterialBanner: true,
                ),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
            }
            if (state is MedicineActionSuccess) {
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Done',
                  message:
                  state.message,
                  contentType: ContentType.success,
                ),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
            }
          },
          builder: (context, state) {
            if (state is MedicineLoading && state.medicines.isEmpty) {
              return const Center(child: LoadingIndicator());
            }

            final medicines = state.medicines;
            if (medicines.isEmpty && state is! MedicineLoading) {
              return _buildEmptyState(context);
            }
            final effectiveTaken = Map<String, bool>.from(state.takenMap);
            effectiveTaken.addAll(_optimisticTaken);
            final now = DateTime.now();
            final Map<String, List<MedicineReminder>> categories = {
              'dueNow': [],
              'upcoming': [],
              'paused': [],
              'taken': [],
            };

            for (final med in medicines) {
              final isTaken = effectiveTaken[med.id] ?? false;

              if (!med.isActive) {
                categories['paused']!.add(med);
              } else if (isTaken) {
                categories['taken']!.add(med);
              } else if (med.isDueNow(currentTime: now)) {
                categories['dueNow']!.add(med);
              } else {
                categories['upcoming']!.add(med);
              }
            }

            final dueNow = categories['dueNow']!;
            final upcoming = categories['upcoming']!;
            final paused = categories['paused']!;
            final taken = categories['taken']!;

            final done = taken.length;
            final total = medicines.where((m) => m.isActive).length;
            final due = dueNow.length;

            return RefreshIndicator(
              onRefresh: () async {
                _optimisticTaken.clear();
                context.read<MedicineBloc>().add(const LoadTodaysMedicines());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildProgressHeader(
                      context,
                      done,
                      total,
                      due,
                    ),
                  ),

                  // Due Now Section
                  if (dueNow.isNotEmpty) ...[
                    _sectionTitle("Due Now (${dueNow.length})", Colors.orange),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _MedicineCard(
                          medicine: dueNow[index],
                          isTaken: effectiveTaken[dueNow[index].id] ?? false,
                          isPaused: false,
                          onToggle: (newTaken) => _handleToggleTaken(
                            context,
                            dueNow[index],
                            newTaken,
                          ),
                          onToggleActive: (newActive) => _handleToggleActive(
                            context,
                            dueNow[index],
                            newActive,
                          ),
                        ),
                        childCount: dueNow.length,
                      ),
                    ),
                  ],

                  // Upcoming Section
                  if (upcoming.isNotEmpty) ...[
                    _sectionTitle("Upcoming (${upcoming.length})", Colors.blue),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _MedicineCard(
                          medicine: upcoming[index],
                          isTaken: effectiveTaken[upcoming[index].id] ?? false,
                          isPaused: false,
                          onToggle: (newTaken) => _handleToggleTaken(
                            context,
                            upcoming[index],
                            newTaken,
                          ),
                          onToggleActive: (newActive) => _handleToggleActive(
                            context,
                            upcoming[index],
                            newActive,
                          ),
                        ),
                        childCount: upcoming.length,
                      ),
                    ),
                  ],
                  if (paused.isNotEmpty) ...[
                    _sectionTitle("Paused (${paused.length})", Colors.grey),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _MedicineCard(
                          medicine: paused[index],
                          isTaken: effectiveTaken[paused[index].id] ?? false,
                          isPaused: true,
                          onToggle: (newTaken) => _handleToggleTaken(
                            context,
                            paused[index],
                            newTaken,
                          ),
                          onToggleActive: (newActive) => _handleToggleActive(
                            context,
                            paused[index],
                            newActive,
                          ),
                        ),
                        childCount: paused.length,
                      ),
                    ),
                  ],
                  if (taken.isNotEmpty) ...[
                    _sectionTitle("Taken Today (${taken.length})", Colors.green),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _MedicineCard(
                          medicine: taken[index],
                          isTaken: true,
                          isPaused: !taken[index].isActive,
                          onToggle: (newTaken) => _handleToggleTaken(
                            context,
                            taken[index],
                            newTaken,
                          ),
                          onToggleActive: (newActive) => _handleToggleActive(
                            context,
                            taken[index],
                            newActive,
                          ),
                        ),
                        childCount: taken.length,
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _sectionTitle(String title, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              color: color,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleToggleTaken(
      BuildContext context,
      MedicineReminder medicine,
      bool newTaken,
      ) {
    if (!medicine.isActive) return;

    final currentTaken = _optimisticTaken[medicine.id] ??
        (context.read<MedicineBloc>().state).takenMap[medicine.id] ?? false;

    if (newTaken == currentTaken) return;

    // Optimistic update
    setState(() {
      _optimisticTaken[medicine.id] = newTaken;
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isFirstDoseOfDay = newTaken &&
        (medicine.lastTakenDateTime == null ||
            medicine.lastTakenDateTime!.isBefore(today));

    // Send to bloc
    context.read<MedicineBloc>().add(
      MarkTakenEvent(
        medicineId: medicine.id,
        taken: newTaken,
        isFirstDoseOfDay: isFirstDoseOfDay,
      ),
    );

    late final StreamSubscription<MedicineState> sub;
    sub = context.read<MedicineBloc>().stream.listen((blocState) {
      if (blocState is MedicineError) {
        // Revert on error
        setState(() {
          _optimisticTaken.remove(medicine.id);
        });
        sub.cancel();
      } else if (blocState is MedicineActionSuccess) {
        // Clear optimistic state on success
        setState(() {
          _optimisticTaken.remove(medicine.id);
        });
        sub.cancel();
      }
    });
  }
  void _handleToggleActive(
      BuildContext context,
      MedicineReminder medicine,
      bool newActive,
      ) {
    context.read<MedicineBloc>().add(
      ToggleActiveEvent(
        medicineId: medicine.id,
        active: newActive,
      ),
    );
  }

  Widget _buildProgressHeader(
      BuildContext context,
      int done,
      int total,
      int due,
      ) {
    final progress = total == 0 ? 0.0 : done / total;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: due > 0
              ? [Colors.orange.shade200, Colors.orange]
              : [
            Colors.blueAccent,
            Colors.blue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    due > 0 ? "$due due now" : "Great progress!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${(progress * 100).toInt()}% • $done of $total done",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            valueColor: AlwaysStoppedAnimation<Color>(
              due > 0 ? Colors.white : Colors.lightGreenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MedicineBloc>().add(const LoadTodaysMedicines());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AssetsManager.emptyGif,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  "No medicines for today",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add your first medicine to get started",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    "Add Medicine",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
          ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final MedicineReminder medicine;
  final bool isTaken;
  final bool isPaused;
  final ValueChanged<bool> onToggle;
  final ValueChanged<bool> onToggleActive;

  const _MedicineCard({
    required this.medicine,
    required this.isTaken,
    required this.isPaused,
    required this.onToggle,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final timeUntil = medicine.getFormattedTimeUntilNext();
    final isDue = medicine.isDueNow();

    Color getCategoryColor() {
      if (isPaused) return Colors.grey;
      if (isTaken) return Colors.green;
      if (isDue) return Colors.orange;
      return Colors.blue;
    }

    IconData getCategoryIcon() {
      if (isPaused) return Icons.pause_circle_outline;
      if (isTaken) return Icons.check_circle_outline;
      if (isDue) return Icons.notifications_active;
      return Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getCategoryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            getCategoryIcon(),
            color: getCategoryColor(),
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                medicine.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: isTaken ? TextDecoration.lineThrough : null,
                  color: isTaken ? Colors.grey : Colors.black,
                ),
              ),
            ),
            if (isPaused)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Paused',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              medicine.purpose,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                decoration: isTaken ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isPaused ? 'Paused • Every ${medicine.hourInterval}h' :
              isTaken ? 'Taken today • Every ${medicine.hourInterval}h' :
              isDue ? 'Due now! • Every ${medicine.hourInterval}h' :
              'Next in $timeUntil • Every ${medicine.hourInterval}h',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: isPaused
            ? IconButton(
          icon: Icon(
            Icons.play_arrow_rounded,
            color: Colors.green.shade600,
          ),
          onPressed: () => onToggleActive(true),
        )
            : Checkbox(
          value: isTaken,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          activeColor: Colors.green,
          onChanged: (v) {
            if (v != null && v != isTaken) {
              onToggle(v);
            }
          },
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditMedicinePage(medicine: medicine),
            fullscreenDialog: true,
          ),
        ).then((_) {
          if (context.mounted) {
            context.read<MedicineBloc>().add(const LoadTodaysMedicines());
          }
        }),
      ),
    );
  }
}