import 'package:coloncare/core/navigation/app_router.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:coloncare/features/home/presentation/blocs/nav_bloc/navigation_bloc.dart';
import 'package:coloncare/features/home/presentation/pages/home_page.dart';
import 'package:coloncare/features/medicine/presentation/pages/medicine_today_page.dart';
import 'package:coloncare/features/predict/presentation/pages/prediction_history_page.dart';
import 'package:coloncare/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainNavigation extends StatelessWidget {
  MainNavigation({super.key});

  final List<Widget> _pages = [
    const HomePage(),
    const PredictionHistoryPage(),
    const MedicineTodayPage(),

    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NavigationBloc>(
      create: (context) => NavigationBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.login,
                  (route) => false,
            );
          }
        },
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, navState) {
            final selectedIndex = navState.selectedIndex;

            return Scaffold(
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                reverseDuration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  const begin = 0.94;
                  const end = 1.0;
                  final scaleAnimation = Tween<double>(begin: begin, end: end).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutSine,
                    ),
                  );

                  return ScaleTransition(
                    scale: scaleAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(selectedIndex),
                  child: _pages[selectedIndex],
                ),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.blue.withOpacity(0.08),
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: GNav(
                      rippleColor: Colors.blue.shade100,
                      hoverColor: Colors.grey[500]!,
                      gap: 4,
                      activeColor: Colors.blue.shade400,
                      iconSize: 22,
                      haptic: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      duration: const Duration(milliseconds: 500),
                      color: Colors.blue.shade200,
                      tabBackgroundColor: Colors.blue.withOpacity(0.1),
                      tabBorderRadius: 22.0,
                      tabs: List.generate(4, (index) {
                        final icons = [
                          Icons.home_outlined,
                          Icons.history,
                          Icons.medical_information_outlined,
                          Icons.settings_suggest_rounded,
                        ];
                        final texts = ['Home', "History", "Medicine", "Settings"];
                        return GButton(
                          icon: icons[index],
                          text: texts[index],
                          border: selectedIndex == index
                              ? Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1.0,
                          )
                              : null,
                        );
                      }),
                      selectedIndex: selectedIndex,
                      onTabChange: (index) {
                        context.read<NavigationBloc>().add(ChangeTab(index));
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}