import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:equatable/equatable.dart';


abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

// Initial state
class HomeInitial extends HomeState {}

// Loading state
class HomeLoading extends HomeState {}

// Loaded state
class HomeLoaded extends HomeState {
  final User user;
  final String welcomeMessage;

  const HomeLoaded({
    required this.user,
    this.welcomeMessage = 'Welcome back!',
  });

  @override
  List<Object> get props => [user, welcomeMessage];
}

// Error state
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}