import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

// Load home data
class HomeDataRequested extends HomeEvent {
  final User? user;

  const HomeDataRequested({this.user});

  @override
  List<Object> get props => [user ?? User.empty];
}

// Refresh home data
class HomeDataRefreshed extends HomeEvent {}

// Logout from home
class HomeLogoutRequested extends HomeEvent {}