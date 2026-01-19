part of 'chatbot_bloc.dart';

abstract class ChatbotEvent extends Equatable {
  const ChatbotEvent();

  @override
  List<Object> get props => [];
}

class ChatbotMessageSent extends ChatbotEvent {
  final String message;

  const ChatbotMessageSent(this.message);

  @override
  List<Object> get props => [message];
}

class ChatbotMessageCleared extends ChatbotEvent {}

class ChatbotConversationStarted extends ChatbotEvent {}

class ChatbotErrorCleared extends ChatbotEvent {}