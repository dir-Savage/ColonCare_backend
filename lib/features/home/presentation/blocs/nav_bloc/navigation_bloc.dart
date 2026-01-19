// lib/features/navigation/presentation/bloc/navigation_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(selectedIndex: 0)) {
    on<ChangeTab>((event, emit) {
      emit(NavigationState(selectedIndex: event.index));
    });
  }
}