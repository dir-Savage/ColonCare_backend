import 'dart:async';
import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/features/health_check/blocs/health_check_bloc.dart';
import 'package:coloncare/features/health_check/presentation/widgets/health_check_dialog.dart';
import 'package:coloncare/features/home/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:coloncare/features/home/presentation/blocs/home_bloc/home_event.dart';
import 'package:coloncare/features/home/presentation/blocs/home_bloc/home_state.dart';
import 'package:coloncare/features/home/presentation/widgets/home_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injector.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HealthCheckBloc>(
          create: (_) => getIt<HealthCheckBloc>(),
        ),
      ],
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  bool _dialogIsOpen = false;

  @override
  void initState() {
    super.initState();

    // Initialize health check ONLY - NO motivational messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final healthCheckBloc = context.read<HealthCheckBloc>();
        healthCheckBloc.add(const CheckForQuestions());
      }
    });
  }

  void _showAppropriateDialog(HealthCheckState state, BuildContext context) {
    if (_dialogIsOpen) return;

    _dialogIsOpen = true;

    // Determine if dialog can be dismissed
    bool barrierDismissible = false;
    if (state is HealthCheckCompleted && !state.showDoctorCall) {
      barrierDismissible = true; // Allow closing when check is complete without doctor call
    }

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return PopScope(
          canPop: barrierDismissible,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: HealthCheckDialog(),
            ),
          ),
        );
      },
    ).then((_) {
      _dialogIsOpen = false;

      // If questions were completed, save results
      if (state is QuestionsCompleted && context.mounted) {
        context.read<HealthCheckBloc>().add(const CompleteHealthCheck());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HealthCheckBloc, HealthCheckState>(
      listener: (context, state) {
        // ONLY health check dialogs, NO motivational messages
        if (state is QuestionsReady ||
            state is QuestionsCompleted ||
            (state is HealthCheckCompleted && state.showDoctorCall)) {

          // Delay slightly to ensure widget is built
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && !_dialogIsOpen) {
              _showAppropriateDialog(state, context);
            }
          });

        } else if (state is QuestionsNotNeeded ||
            (state is HealthCheckCompleted && !state.showDoctorCall)) {

          // Close dialog if it's showing
          if (_dialogIsOpen && Navigator.canPop(context)) {
            Navigator.pop(context);
            _dialogIsOpen = false;
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
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
            )
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: () {
                          context.read<HomeBloc>().add(HomeDataRefreshed());
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is HomeLoaded) {
              return HomeContent(user: state.user);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}