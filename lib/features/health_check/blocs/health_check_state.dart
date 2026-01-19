part of 'health_check_bloc.dart';

abstract class HealthCheckState extends Equatable {
  const HealthCheckState();

  @override
  List<Object> get props => [];
}

class HealthCheckInitial extends HealthCheckState {}

class HealthCheckLoading extends HealthCheckState {}

class QuestionsReady extends HealthCheckState {
  final List<HealthCheckQuestion> questions;

  const QuestionsReady({required this.questions});

  @override
  List<Object> get props => [questions];
}

class QuestionsCompleted extends HealthCheckState {
  final HealthCheckResult result;

  const QuestionsCompleted({required this.result});

  @override
  List<Object> get props => [result];
}

class HealthCheckCompleted extends HealthCheckState {
  final HealthCheckResult result;
  final bool showDoctorCall;
  final bool skippedToDoctor;

  const HealthCheckCompleted({
    required this.result,
    this.showDoctorCall = false,
    this.skippedToDoctor = false,
  });

  @override
  List<Object> get props => [result, showDoctorCall, skippedToDoctor];
}

class QuestionsNotNeeded extends HealthCheckState {
  final Duration nextCheckIn;

  const QuestionsNotNeeded({required this.nextCheckIn});

  @override
  List<Object> get props => [nextCheckIn];
}

// REMOVED: RandomMessageReady, MessageClosed

class HealthCheckError extends HealthCheckState {
  final String message;

  const HealthCheckError(this.message);

  @override
  List<Object> get props => [message];
}