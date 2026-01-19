import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:equatable/equatable.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthBloc authBloc;
  StreamSubscription? _authSubscription;

  HomeBloc({required this.authBloc}) : super(HomeInitial()) {
    on<HomeDataRequested>(_onHomeDataRequested);
    on<HomeDataRefreshed>(_onHomeDataRefreshed);
    on<HomeLogoutRequested>(_onHomeLogoutRequested);

    // Listen to auth state changes
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is Authenticated) {
        add(HomeDataRequested(user: authState.user));
      } else if (authState is Unauthenticated) {
        add(const HomeDataRequested(user: null));
      }
    });

    // Initial data request
    add(const HomeDataRequested());
  }

  Future<void> _onHomeDataRequested(
      HomeDataRequested event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());

    // Check auth state
    final authState = authBloc.state;

    if (authState is Authenticated) {
      final user = event.user ?? authState.user;
      emit(HomeLoaded(user: user));
    } else {
      emit(const HomeError('Please log in to access this page'));
    }
  }

  Future<void> _onHomeDataRefreshed(
      HomeDataRefreshed event,
      Emitter<HomeState> emit,
      ) async {
    await _onHomeDataRequested(const HomeDataRequested(), emit);
  }

  Future<void> _onHomeLogoutRequested(
      HomeLogoutRequested event,
      Emitter<HomeState> emit,
      ) async {
    authBloc.add(LogoutRequested());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}