import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/core/di/injector.dart';
import 'package:coloncare/core/navigation/app_router.dart';
import 'package:coloncare/core/utils/app_animations.dart';
import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:coloncare/features/home/presentation/blocs/home_bloc/home_event.dart';
import 'package:coloncare/features/home/presentation/widgets/home_user_info.dart';
import 'package:coloncare/features/medicine/domain/entities/medicine_reminder.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_event.dart';
import 'package:coloncare/features/medicine/presentation/widgets/medicine_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../blocs/home_bloc/home_bloc.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_bloc.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_state.dart';

class HomeContent extends StatelessWidget {
  final User user;

  const HomeContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(HomeDataRefreshed());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInAnimation(
                child: HomeUserInfo(
                  user: user,
                ),
              ),

              // MEDICINE STATS SECTION - BEAUTIFUL WITH SHIMMER & ANIMATIONS
              const SizedBox(height: 30),
              BlocProvider(
                create: (context) => getIt<MedicineBloc>()..add(const LoadTodaysMedicines()),
                child: BlocBuilder<MedicineBloc, MedicineState>(
                  builder: (context, medicineState) {
                    // SHIMMER LOADING EFFECT
                    if (medicineState is MedicineLoading && medicineState.medicines.isEmpty) {
                      return _buildShimmerLoading();
                    }

                    List<MedicineReminder> medicines = [];
                    Map<String, bool> takenMap = {};

                    if (medicineState is TodaysMedicinesLoaded) {
                      medicines = medicineState.medicines;
                      takenMap = medicineState.takenMap;
                    } else if (medicineState is AllMedicinesLoaded) {
                      medicines = medicineState.medicines;
                      takenMap = medicineState.takenMap;
                    } else if (medicineState is MedicineActionSuccess) {
                      medicines = medicineState.medicines;
                      takenMap = medicineState.takenMap;
                    } else if (medicineState is MedicineLoading) {
                      // Show shimmer loading with existing data if any
                      if (medicineState.medicines.isNotEmpty) {
                        medicines = medicineState.medicines;
                        takenMap = medicineState.takenMap;
                        final stats = MedicineStats(medicines: medicines, takenMap: takenMap);
                        return _buildStatsWithPulseEffect(context, stats);
                      }
                      return _buildShimmerLoading();
                    }

                    if (medicines.isEmpty) {
                      return ScaleInAnimation(
                        delay: 200,
                        child: _buildEmptyMedicineCard(context),
                      );
                    }

                    final stats = MedicineStats(medicines: medicines, takenMap: takenMap);

                    return Column(
                      children: [
                        // MAIN PROGRESS CARD WITH GLASS EFFECT
                        ScaleInAnimation(
                          delay: 100,
                          child: _buildGlassProgressCard(context, stats),
                        ),

                        const SizedBox(height: 15),

                        // STATS CARDS WITH STAGGERED ANIMATION
                        SlideInAnimation(
                          delay: 200,
                          direction: SlideDirection.left,
                          child: _buildStatsRow(context, stats),
                        ),

                        const SizedBox(height: 10),

                        // QUICK ACTIONS WITH FLOAT ANIMATION
                        SlideInAnimation(
                          delay: 300,
                          direction: SlideDirection.right,
                          child: _buildQuickActions(context),
                        ),

                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),

              // EXISTING CONTENT BELOW - NO CHANGES
              const SizedBox(height: 20),
              FadeInAnimation(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.bmiCalculator);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInAnimation(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.blue.shade400,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Select",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          const FadeInText(
                            'your condition for personalized diagnosis.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              FadeInText(
                'Features',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade500,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  _buildFeatureCard(
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.prediction);
                    },
                    context,
                    imagePath: AssetsManager.colonImage,
                    description: 'Scan your colon images for early detection \nwith advanced AI.',
                    icon: Icons.security,
                    title: 'COLON SCAN PREDICTION',
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  _buildFeatureCard(
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.chatbot);
                    },
                    context,
                    imagePath: AssetsManager.chatbotCover,
                    description: 'Get instant answers and support from our AI-powered chatbot assistant.',
                    icon: Icons.security,
                    title: 'START CHATBOT ASSISTANT',
                    color: Colors.black,
                  )
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const FadeInText(
                      'Secure App v1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FadeInText(
                      'Logged in as: ${user.email}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // BEAUTIFUL CUSTOM WIDGETS
  // ============================

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 290,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: List.generate(3, (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 8, right: index == 2 ? 0 : 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildStatsWithPulseEffect(BuildContext context, MedicineStats stats) {
    return Column(
      children: [
        PulseAnimation(
          child: _buildGlassProgressCard(context, stats),
        ),
        const SizedBox(height: 15),
        Row(
          children: List.generate(3, (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 8, right: index == 2 ? 0 : 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: _buildStatCardItem(
                  index == 0 ? 'Total' : index == 1 ? 'Active' : 'Due',
                  index == 0 ? stats.totalMedicines.toString() :
                  index == 1 ? stats.activeMedicines.toString() :
                  stats.dueNow.toString(),
                  index == 0 ? Colors.blue : index == 1 ? Colors.green : Colors.orange,
                  index == 0 ? Icons.medication : index == 1 ? Icons.check_circle : Icons.notifications_active,
                ),
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildGlassProgressCard(BuildContext context, MedicineStats stats) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.medicineToday);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Animated Progress Ring
            ScaleInAnimation(
              delay: 100,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.2),
                          Colors.green.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: stats.completionRate,
                      strokeWidth: 8,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(stats.completionRate * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInText(
                    'Medicine Tracker',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${stats.takenToday} of ${stats.activeMedicines} medicines taken',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Animated Progress Bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut,
                      alignment: Alignment.centerLeft,
                      widthFactor: stats.completionRate,
                      heightFactor: 1.2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green,
                              Colors.lightGreen,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Mini Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStatWithIcon(
                        icon: Icons.notifications_active,
                        value: stats.dueNow.toString(),
                        label: 'Due Now',
                        color: Colors.orange,
                      ),
                      _buildMiniStatWithIcon(
                        icon: Icons.schedule,
                        value: stats.upcoming.toString(),
                        label: 'Upcoming',
                        color: Colors.blue,
                      ),
                      _buildMiniStatWithIcon(
                        icon: Icons.pause_circle,
                        value: stats.pausedMedicines.toString(),
                        label: 'Paused',
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, MedicineStats stats) {
    return Row(
      children: [
        _buildStatCard(
          context: context,
          title: 'Total Medicines',
          value: stats.totalMedicines.toString(),
          icon: Icons.medication,
          color: Colors.blue,
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
          ),
        ),

        const SizedBox(width: 10),

        _buildStatCard(
          context: context,
          title: 'Active',
          value: stats.activeMedicines.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade200],
          ),
        ),

        const SizedBox(width: 10),

        _buildStatCard(
          context: context,
          title: 'Taken Today',
          value: stats.takenToday.toString(),
          icon: Icons.done_all,
          color: Colors.purple,
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.purple.shade200],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRouter.medicineToday);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionButton(
            icon: Icons.add,
            label: 'Add',
            color: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.medicineToday);
            },
          ),
          _buildQuickActionButton(
            icon: Icons.bar_chart,
            label: 'Stats',
            color: Colors.green,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.medicineStats);
            },
          ),
          _buildQuickActionButton(
            icon: Icons.list,
            label: 'All',
            color: Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.medicineAll);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMedicineCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.medicineToday);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.blue.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.blue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Start Tracking Medicines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first medicine to begin your health journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlue],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Add First Medicine',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatWithIcon({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardItem(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // EXISTING FEATURE CARD - NO CHANGES
  // ============================
  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required String imagePath,
        required Color color,
        final VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: FadeInAnimation(
        child: Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(color.withOpacity(0.26), BlendMode.darken),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
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

// ============================
// CUSTOM ANIMATIONS
// ============================

enum SlideDirection { left, right, up, down }

class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final int delay;

  const ScaleInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = 0,
  });

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final int delay;
  final SlideDirection direction;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = 0,
    this.direction = SlideDirection.up,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.left:
        beginOffset = const Offset(-1, 0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(1, 0);
        break;
      case SlideDirection.up:
        beginOffset = const Offset(0, 1);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0, -1);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: widget.child,
    );
  }
}

class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final double heightFactor;
  final Widget child;
  final AlignmentGeometry alignment;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.heightFactor,
    required this.child,
    this.alignment = Alignment.center,
    super.duration = const Duration(milliseconds: 300),
    super.curve = Curves.easeInOut,
  });

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;
  Tween<double>? _heightFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
          (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;

    _heightFactor = visitor(
      _heightFactor,
      widget.heightFactor,
          (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      heightFactor: _heightFactor?.evaluate(animation) ?? widget.heightFactor,
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}