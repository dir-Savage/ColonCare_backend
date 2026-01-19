import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_question.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_result.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_settings.dart';
import 'package:coloncare/features/health_check/domain/repositories/health_check_repository.dart';
import 'package:coloncare/features/health_check/domain/usecases/save_health_check_result_usecase.dart';
import 'package:coloncare/features/health_check/domain/usecases/should_show_questions_usecase.dart';
import 'package:equatable/equatable.dart';

part 'health_check_event.dart';
part 'health_check_state.dart';

class HealthCheckBloc extends Bloc<HealthCheckEvent, HealthCheckState> {
  final ShouldShowQuestionsUseCase shouldShowQuestionsUseCase;
  final SaveHealthCheckResultUseCase saveHealthCheckResultUseCase;
  final HealthCheckRepository repository;

  Timer? _questionsTimer;

  HealthCheckBloc({
    required this.shouldShowQuestionsUseCase,
    required this.saveHealthCheckResultUseCase,
    required this.repository,
  }) : super(HealthCheckInitial()) {
    on<CheckForQuestions>(_onCheckForQuestions);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<CompleteHealthCheck>(_onCompleteHealthCheck);
    on<ResetQuestionsTimer>(_onResetQuestionsTimer);
    on<SkipToDoctorCall>(_onSkipToDoctorCall);

    // Initial check
    add(const CheckForQuestions());
  }

  Future<void> _onCheckForQuestions(
      CheckForQuestions event,
      Emitter<HealthCheckState> emit,
      ) async {
    try {
      final result = await shouldShowQuestionsUseCase();

      result.fold(
            (failure) => emit(HealthCheckError(failure.message)),
            (shouldShow) async {
          if (shouldShow) {
            final questions = _getRandomQuestions(2);
            emit(QuestionsReady(questions: questions));
          } else {
            final nextCheck = repository.getTimeUntilNextCheck();
            emit(QuestionsNotNeeded(nextCheckIn: await nextCheck));
            _scheduleNextCheck();
          }
        },
      );
    } catch (e) {
      emit(HealthCheckError('Failed to check for questions: $e'));
    }
  }

  Future<void> _onAnswerQuestion(
      AnswerQuestion event,
      Emitter<HealthCheckState> emit,
      ) async {
    if (state is QuestionsReady) {
      final currentState = state as QuestionsReady;
      final updatedQuestions = List<HealthCheckQuestion>.from(currentState.questions);

      final index = updatedQuestions.indexWhere((q) => q.id == event.questionId);
      if (index != -1) {
        updatedQuestions[index] = updatedQuestions[index].copyWith(
          answer: event.answer,
        );
      }

      emit(QuestionsReady(questions: updatedQuestions));

      final allAnswered = updatedQuestions.every((q) => q.answer.isNotEmpty);
      if (allAnswered) {
        final result = _calculateResults(updatedQuestions);
        emit(QuestionsCompleted(result: result));
      }
    }
  }

  Future<void> _onCompleteHealthCheck(
      CompleteHealthCheck event,
      Emitter<HealthCheckState> emit,
      ) async {
    if (state is QuestionsCompleted) {
      final currentState = state as QuestionsCompleted;

      try {
        final result = await saveHealthCheckResultUseCase(currentState.result);

        result.fold(
              (failure) => emit(HealthCheckError(failure.message)),
              (_) async {
            // Get current settings to know the interval
            final settings = await repository.getHealthCheckSettings();

            emit(HealthCheckCompleted(
              result: currentState.result,
              showDoctorCall: currentState.result.riskLevel == RiskLevel.high ||
                  currentState.result.riskLevel == RiskLevel.medium,
            ));

            // Reset timer with custom interval from settings
            _resetQuestionsTimer(settings.checkInterval);
          },
        );
      } catch (e) {
        emit(HealthCheckError('Failed to save health check: $e'));
      }
    }
  }

  void _onResetQuestionsTimer(
      ResetQuestionsTimer event,
      Emitter<HealthCheckState> emit,
      ) {
    _resetQuestionsTimer(const Duration(hours: 10));
    emit(const QuestionsNotNeeded(nextCheckIn: Duration(hours: 10)));
  }

  void _onSkipToDoctorCall(
      SkipToDoctorCall event,
      Emitter<HealthCheckState> emit,
      ) {
    if (state is QuestionsCompleted) {
      final currentState = state as QuestionsCompleted;
      emit(HealthCheckCompleted(
        result: currentState.result,
        showDoctorCall: true,
        skippedToDoctor: true,
      ));
    }
  }

  List<HealthCheckQuestion> _getRandomQuestions(int count) {
    final allQuestions = [
      HealthCheckQuestion(
        id: '1',
        question: 'How are you feeling right now?',
        options: ['Very good', 'Good', 'Okay', 'Not well'],
        type: QuestionType.feeling,
      ),
      HealthCheckQuestion(
        id: '2',
        question: 'Are you experiencing any new or unusual symptoms today?',
        options: ['Yes', 'No'],
        type: QuestionType.symptoms,
      ),
      HealthCheckQuestion(
        id: '3',
        question: 'Have you been able to eat and drink comfortably today?',
        options: ['Yes', 'A little', 'Not yet'],
        type: QuestionType.nutrition,
      ),
      HealthCheckQuestion(
        id: '4',
        question: 'Did you take your prescribed medication as scheduled?',
        options: ['Yes', 'Missed a dose', 'Not scheduled today'],
        type: QuestionType.medication,
      ),
    ];

    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }

  HealthCheckResult _calculateResults(List<HealthCheckQuestion> questions) {
    int score = 0;
    final answers = <String, String>{};

    for (final question in questions) {
      answers[question.id] = question.answer;

      switch (question.type) {
        case QuestionType.feeling:
          if (question.answer == 'Not well') score += 3;
          if (question.answer == 'Okay') score += 1;
          break;
        case QuestionType.symptoms:
          if (question.answer == 'Yes') score += 3;
          break;
        case QuestionType.nutrition:
          if (question.answer == 'Not yet') score += 2;
          if (question.answer == 'A little') score += 1;
          break;
        case QuestionType.medication:
          if (question.answer == 'Missed a dose') score += 2;
          break;
      }
    }

    RiskLevel riskLevel;
    if (score >= 4) {
      riskLevel = RiskLevel.high;
    } else if (score >= 2) {
      riskLevel = RiskLevel.medium;
    } else {
      riskLevel = RiskLevel.low;
    }

    return HealthCheckResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      answers: answers,
      score: score,
      riskLevel: riskLevel,
      timestamp: DateTime.now(),
    );
  }

  void _scheduleNextCheck() async {
    _questionsTimer?.cancel();
    final settings = await repository.getHealthCheckSettings();
    _questionsTimer = Timer(settings.checkInterval, () {
      add(const CheckForQuestions());
    });
  }

  void _resetQuestionsTimer(Duration interval) {
    _questionsTimer?.cancel();
    _questionsTimer = Timer(interval, () {
      add(const CheckForQuestions());
    });
  }

  @override
  Future<void> close() {
    _questionsTimer?.cancel();
    return super.close();
  }
}