import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object> get props => [];
}

// Check authentication status
class SplashAuthCheckRequested extends SplashEvent {
  final BuildContext? context;

  const SplashAuthCheckRequested({this.context});

  @override
  List<Object> get props => [];
}