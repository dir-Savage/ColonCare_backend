part of 'chat_animations_bloc.dart';

abstract class ChatAnimationsEvent extends Equatable {
  const ChatAnimationsEvent();

  @override
  List<Object> get props => [];
}

class MessageAdded extends ChatAnimationsEvent {
  final String messageId;
  final bool isUser;

  const MessageAdded({
    required this.messageId,
    required this.isUser,
  });

  @override
  List<Object> get props => [messageId, isUser];
}

class MessageBubbleAnimated extends ChatAnimationsEvent {
  final String messageId;

  const MessageBubbleAnimated(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class MessageTypingStarted extends ChatAnimationsEvent {
  final String messageId;

  const MessageTypingStarted(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class MessageTypingComplete extends ChatAnimationsEvent {
  final String messageId;

  const MessageTypingComplete(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class AllAnimationsComplete extends ChatAnimationsEvent {}

class ResetAnimations extends ChatAnimationsEvent {}