import 'package:equatable/equatable.dart';

enum QuestionType {
  feeling,
  symptoms,
  nutrition,
  medication,
}

class HealthCheckQuestion extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final QuestionType type;
  final String answer;

  const HealthCheckQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.type,
    this.answer = '',
  });

  HealthCheckQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    QuestionType? type,
    String? answer,
  }) {
    return HealthCheckQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      type: type ?? this.type,
      answer: answer ?? this.answer,
    );
  }

  @override
  List<Object> get props => [id, question, options, type, answer];
}