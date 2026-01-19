import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthBloc authBloc;
  StreamSubscription? _authSubscription;

  SplashBloc({required this.authBloc}) : super(SplashInitial()) {
    on<SplashAuthCheckRequested>(_onSplashAuthCheckRequested);
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSplashAuthCheckRequested(
      SplashAuthCheckRequested event,
      Emitter<SplashState> emit,
      ) async {
    emit(SplashLoading());

    // Wait for minimum splash time
    await Future.delayed(const Duration(milliseconds: 1500));

    // FIRST: Trigger auth check
    authBloc.add(AuthCheckRequested());

    // Listen to auth state changes with timeout
    final completer = Completer<void>();
    bool hasResult = false;

    _authSubscription?.cancel(); // Cancel any existing subscription
    _authSubscription = authBloc.stream.listen((authState) {
      if (!hasResult) {
        if (authState is Authenticated) {
          hasResult = true;
          completer.complete();
          emit(SplashAuthenticated());
        } else if (authState is Unauthenticated) {
          hasResult = true;
          completer.complete();
          emit(SplashUnauthenticated());
        } else if (authState is AuthError) {
          hasResult = true;
          completer.complete();
          emit(SplashUnauthenticated()); // On error, go to login
        }
        // Ignore AuthLoading and AuthInitial states
      }
    });

    // Set timeout
    await Future.any([
      completer.future,
      Future.delayed(const Duration(seconds: 5)).then((_) {
        if (!hasResult) {
          emit(SplashUnauthenticated());
        }
      }),
    ]);

    _authSubscription?.cancel();
  }
}