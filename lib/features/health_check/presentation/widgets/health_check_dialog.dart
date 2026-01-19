import 'package:coloncare/features/health_check/blocs/health_check_bloc.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_question.dart';
import 'package:coloncare/features/health_check/domain/entities/health_check_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthCheckDialog extends StatelessWidget {
  const HealthCheckDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthCheckBloc, HealthCheckState>(
      builder: (context, state) {
        if (state is QuestionsReady) {
          return _QuestionsDialog(questions: state.questions);
        }

        if (state is QuestionsCompleted) {
          return _ResultsDialog(result: state.result);
        }

        if (state is HealthCheckCompleted && state.showDoctorCall) {
          return _DoctorCallDialog(
            result: state.result,
            skippedToDoctor: state.skippedToDoctor,
          );
        }

        // Default empty container
        return const SizedBox.shrink();
      },
    );
  }
}

class _QuestionsDialog extends StatefulWidget {
  final List<HealthCheckQuestion> questions;

  const _QuestionsDialog({required this.questions});

  @override
  State<_QuestionsDialog> createState() => _QuestionsDialogState();
}

class _QuestionsDialogState extends State<_QuestionsDialog> {
  int _currentQuestionIndex = 0;

  HealthCheckQuestion get _currentQuestion => widget.questions[_currentQuestionIndex];

  bool get _isLastQuestion => _currentQuestionIndex == widget.questions.length - 1;

  void _answerQuestion(String answer) {
    context.read<HealthCheckBloc>().add(
      AnswerQuestion(
        questionId: _currentQuestion.id,
        answer: answer,
      ),
    );

    if (_isLastQuestion) {
      return;
    }

    setState(() {
      _currentQuestionIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with flexible spacing
            _buildHeader(context),

            // Question text with flexible height
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _currentQuestion.question,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Options with flexible layout
            _buildOptions(),

            // Next button if needed
            if (_currentQuestion.answer.isNotEmpty && !_isLastQuestion)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    },
                    child: const Text('Next Question'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Check',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _currentQuestion.options
          .map(
            (option) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _answerQuestion(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                alignment: Alignment.centerLeft,
              ),
              child: Text(
                option,
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

class _ResultsDialog extends StatelessWidget {
  final HealthCheckResult result;

  const _ResultsDialog({required this.result});

  Color _getRiskColor() {
    switch (result.riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  String _getRiskTitle() {
    switch (result.riskLevel) {
      case RiskLevel.low:
        return 'Good News!';
      case RiskLevel.medium:
        return 'Attention Needed';
      case RiskLevel.high:
        return 'Important Notice';
    }
  }

  IconData _getRiskIcon() {
    switch (result.riskLevel) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();
    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_getRiskIcon(), color: riskColor, size: 28),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    _getRiskTitle(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Risk description
            Text(
              result.riskDescription,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            // Doctor recommendation if needed
            if (result.shouldCallDoctor)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: riskColor.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.medical_services, color: riskColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Based on your responses, we recommend contacting your doctor.',
                        style: TextStyle(
                          fontSize: 14,
                          color: riskColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Buttons
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (result.shouldCallDoctor)
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<HealthCheckBloc>().add(const SkipToDoctorCall());
                        },
                        child: Text(
                          'Skip to Doctor Call',
                          style: TextStyle(
                            color: riskColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<HealthCheckBloc>().add(const CompleteHealthCheck());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: riskColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCallDialog extends StatelessWidget {
  final HealthCheckResult result;
  final bool skippedToDoctor;

  const _DoctorCallDialog({
    required this.result,
    required this.skippedToDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.phone, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Contact Your Doctor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            if (!skippedToDoctor)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Based on your health check responses, we strongly recommend contacting your doctor for further evaluation.',
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                ],
              ),

            const Text(
              'Your doctor can provide personalized medical advice based on your current condition.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Information container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'When calling your doctor, be ready to describe:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint('Your current symptoms'),
                        _buildBulletPoint('When symptoms started'),
                        _buildBulletPoint('Any medications you\'re taking'),
                        _buildBulletPoint('Your recent health check results'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Not Now',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call Doctor'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}