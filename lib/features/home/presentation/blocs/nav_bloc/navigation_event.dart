// lib/features/navigation/presentation/bloc/navigation_event.dart
part of 'navigation_bloc.dart';

class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class ChangeTab extends NavigationEvent {
  final int index;

  const ChangeTab(this.index);

  @override
  List<Object> get props => [index];
}