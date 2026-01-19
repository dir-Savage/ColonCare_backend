import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/medicine_reminder.dart';

/// ============================================
/// STATISTICS CALCULATOR
/// ============================================
class MedicineStats {
  final List<MedicineReminder> medicines;
  final Map<String, bool> takenMap;

  MedicineStats({
    required this.medicines,
    required this.takenMap,
  });

  int get totalMedicines => medicines.length;

  int get activeMedicines =>
      medicines.where((m) => m.isActive).length;

  int get pausedMedicines =>
      medicines.where((m) => !m.isActive).length;

  int get takenToday => medicines.where((med) {
    final isTaken = takenMap[med.id] ?? false;
    return med.isActive && isTaken;
  }).length;

  int get dueNow {
    final now = DateTime.now();
    return medicines.where((med) {
      final isTaken = takenMap[med.id] ?? false;
      return med.isActive &&
          !isTaken &&
          med.isDueNow(currentTime: now);
    }).length;
  }

  int get upcoming {
    final now = DateTime.now();
    return medicines.where((med) {
      final isTaken = takenMap[med.id] ?? false;
      return med.isActive &&
          !isTaken &&
          !med.isDueNow(currentTime: now);
    }).length;
  }

  double get completionRate {
    final activeMeds = medicines.where((m) => m.isActive);
    if (activeMeds.isEmpty) return 0.0;

    final taken =
        activeMeds.where((m) => takenMap[m.id] ?? false).length;
    return taken / activeMeds.length;
  }

  Map<String, int> get medicinesByFrequency {
    final Map<String, int> map = {};
    for (final med in medicines) {
      final key = '${med.hourInterval}h';
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }
}

/// ============================================
/// WIDGET 1: PROGRESS RING
/// ============================================
class ProgressRingChart extends StatelessWidget {
  final double progress;
  final String title;
  final Color color;

  const ProgressRingChart({
    super.key,
    required this.progress,
    required this.title,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.4),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
              AlwaysStoppedAnimation(Colors.grey.shade200),
            ),
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor:
              AlwaysStoppedAnimation(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// WIDGET 2: STATS GRID
/// ============================================
class StatsCardsGrid extends StatelessWidget {
  final MedicineStats stats;

  const StatsCardsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _card('Total', stats.totalMedicines,
            Icons.medication, Colors.blue),
        _card('Active', stats.activeMedicines,
            Icons.check_circle, Colors.green),
        _card('Taken Today', stats.takenToday,
            Icons.done_all, Colors.purple),
        _card('Due Now', stats.dueNow,
            Icons.notifications_active, Colors.orange),
      ],
    );
  }

  Widget _card(
      String title, int value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// WIDGET 3: PIE CHART
/// ============================================
class MedicineDistributionPie extends StatelessWidget {
  final MedicineStats stats;

  const MedicineDistributionPie({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final sections = _sections();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _legend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _sections() {
    final data = [
      _Cat('Taken', stats.takenToday, Colors.green),
      _Cat('Due', stats.dueNow, Colors.orange),
      _Cat('Upcoming', stats.upcoming, Colors.blue),
      _Cat('Paused', stats.pausedMedicines, Colors.grey),
    ];

    final total =
    data.fold<int>(0, (s, e) => s + e.count);
    if (total == 0) return [];

    return data.map((e) {
      return PieChartSectionData(
        color: e.color,
        value: e.count.toDouble(),
        radius: 50,
        title: e.count == 0 ? '' : '${e.count}',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  Widget _legend() {
    final items = [
      _Cat('Taken', stats.takenToday, Colors.green),
      _Cat('Due', stats.dueNow, Colors.orange),
      _Cat('Upcoming', stats.upcoming, Colors.blue),
      _Cat('Paused', stats.pausedMedicines, Colors.grey),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: e.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(e.name),
              const SizedBox(width: 8),
              Text(
                e.count.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class _Cat {
  final String name;
  final int count;
  final Color color;

  _Cat(this.name, this.count, this.color);
}

/// ============================================
/// WIDGET 4: FREQUENCY BAR CHART
/// ============================================
class FrequencyBarChart extends StatelessWidget {
  final MedicineStats stats;

  const FrequencyBarChart({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final entries =
    stats.medicinesByFrequency.entries.toList();

    if (entries.isEmpty) {
      return _emptyBox('No frequency data available');
    }

    final max = entries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.asMap().entries.map((e) {
          final height = (e.value.value / max) * 100;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _colors[e.key % _colors.length],
                    borderRadius:
                    const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      e.value.value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  e.value.key,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyBox(String text) => Container(
    height: 200,
    decoration: _box(),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey),
      ),
    ),
  );

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];
}

/// ============================================
/// WIDGET 5: WEEKLY TREND
/// ============================================
class WeeklyTrendChart extends StatelessWidget {
  final List<double> weeklyData;

  const WeeklyTrendChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final max =
    weeklyData.isEmpty ? 0 : weeklyData.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      // decoration: FrequencyBarChart._box(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final v = i < weeklyData.length ? weeklyData[i] : 0;
          final h = max == 0 ? 0 : (v / max) * 100;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  // height: h,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.withOpacity(0.8),
                        Colors.blue.withOpacity(0.4),
                      ],
                    ),
                    borderRadius:
                    const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  days[i],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// ============================================
/// DASHBOARD
/// ============================================
class MedicineDashboard extends StatelessWidget {
  final List<MedicineReminder> medicines;
  final Map<String, bool> takenMap;

  const MedicineDashboard({
    super.key,
    required this.medicines,
    required this.takenMap,
  });

  @override
  Widget build(BuildContext context) {
    final stats =
    MedicineStats(medicines: medicines, takenMap: takenMap);

    final weeklyData = [3, 4, 5, 6, 7, 4, 3].map((e) => e.toDouble()).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ProgressRingChart(
                  progress: stats.completionRate,
                  title: 'Today',
                  color: Colors.green,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medicine Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.takenToday} of ${stats.activeMedicines} medicines taken today',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: stats.completionRate,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          StatsCardsGrid(stats: stats),
          const SizedBox(height: 20),
          MedicineDistributionPie(stats: stats),
          const SizedBox(height: 20),
          FrequencyBarChart(stats: stats),
          const SizedBox(height: 20),
          WeeklyTrendChart(weeklyData: weeklyData),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}