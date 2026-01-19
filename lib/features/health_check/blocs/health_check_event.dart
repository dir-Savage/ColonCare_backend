part of 'health_check_bloc.dart';

abstract class HealthCheckEvent extends Equatable {
  const HealthCheckEvent();

  @override
  List<Object> get props => [];
}

class CheckForQuestions extends HealthCheckEvent {
  const CheckForQuestions();
}

class AnswerQuestion extends HealthCheckEvent {
  final String questionId;
  final String answer;

  const AnswerQuestion({
    required this.questionId,
    required this.answer,
  });

  @override
  List<Object> get props => [questionId, answer];
}

class CompleteHealthCheck extends HealthCheckEvent {
  const CompleteHealthCheck();
}

class ResetQuestionsTimer extends HealthCheckEvent {
  const ResetQuestionsTimer();
}

class SkipToDoctorCall extends HealthCheckEvent {
  const SkipToDoctorCall();
}

// REMOVED: ShowRandomMessage, CloseMessageDialog