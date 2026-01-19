// lib/core/di/app_bloc_providers.dart

import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_form_bloc/auth_form_bloc.dart';
import 'package:coloncare/features/health_check/blocs/health_check_bloc.dart';
import 'package:coloncare/features/home/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_bloc.dart';   // ← ADD THIS
import 'package:coloncare/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:coloncare/features/splash/presentation/splash_bloc/splash_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injector.dart';

class AppBlocProviders extends StatelessWidget {
  final Widget child;
  const AppBlocProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Globally needed BLoCs
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<SplashBloc>(create: (_) => getIt<SplashBloc>()),
        BlocProvider<AuthFormBloc>(create: (_) => getIt<AuthFormBloc>()),
        BlocProvider<HomeBloc>(create: (_) => getIt<HomeBloc>()),
        BlocProvider<MedicineBloc>(create: (_) => getIt<MedicineBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => getIt<ProfileBloc>()),
        BlocProvider<HealthCheckBloc>(create: (_) => getIt<HealthCheckBloc>()),
      ],
      child: child,
    );
  }
}