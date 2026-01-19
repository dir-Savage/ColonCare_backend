import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

// Initial state
class SplashInitial extends SplashState {}

// Loading state
class SplashLoading extends SplashState {}

// Authenticated state - navigate to home
class SplashAuthenticated extends SplashState {}

// Unauthenticated state - navigate to login
class SplashUnauthenticated extends SplashState {}

// Error state
class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object> get props => [message];
}