part of 'chatbot_bloc.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? animationKey;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.animationKey,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? animationKey,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      animationKey: animationKey ?? this.animationKey,
    );
  }
}

class ChatbotState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final bool hasError;
  final String currentInput;
  final bool isTypingAnimationComplete;

  const ChatbotState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasError = false,
    this.currentInput = '',
    this.isTypingAnimationComplete = false,
  });

  bool get canSendMessage => currentInput.trim().isNotEmpty && !isLoading;
  bool get isEmpty => messages.isEmpty;
  bool get hasMessages => messages.isNotEmpty;
  bool get showWelcomeMessage => messages.isEmpty && !isLoading;

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool? hasError,
    String? currentInput,
    bool? isTypingAnimationComplete,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      hasError: hasError ?? this.hasError,
      currentInput: currentInput ?? this.currentInput,
      isTypingAnimationComplete: isTypingAnimationComplete ?? this.isTypingAnimationComplete,
    );
  }

  ChatbotState addMessage(ChatMessage message) {
    return copyWith(
      messages: List<ChatMessage>.from(messages)..add(message),
    );
  }

  ChatbotState updateLastMessage(String content) {
    if (messages.isEmpty) return this;

    final updatedMessages = List<ChatMessage>.from(messages);
    final lastIndex = updatedMessages.length - 1;
    updatedMessages[lastIndex] = updatedMessages[lastIndex].copyWith(
      content: content,
      animationKey: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    return copyWith(messages: updatedMessages);
  }

  ChatbotState removeMessage(String id) {
    return copyWith(
      messages: messages.where((message) => message.id != id).toList(),
    );
  }

  ChatbotState clearError() {
    return copyWith(
      errorMessage: null,
      hasError: false,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isLoading,
    errorMessage,
    hasError,
    currentInput,
    isTypingAnimationComplete,
  ];
}

// Initial state - welcome state
class ChatbotInitial extends ChatbotState {
  const ChatbotInitial() : super();
}

// Loading state - when sending message
class ChatbotLoading extends ChatbotState {
  final List<ChatMessage> existingMessages;

  const ChatbotLoading({
    required this.existingMessages,
  }) : super(
    messages: existingMessages,
    isLoading: true,
  );

  @override
  List<Object?> get props => [existingMessages, isLoading];
}

// Loaded state - when response received
class ChatbotLoaded extends ChatbotState {
  final List<ChatMessage> allMessages;
  final ChatMessage lastBotMessage;
  final bool typingAnimationInProgress;

  const ChatbotLoaded({
    required this.allMessages,
    required this.lastBotMessage,
    this.typingAnimationInProgress = true,
  }) : super(
    messages: allMessages,
    isLoading: false,
  );

  @override
  List<Object?> get props => [allMessages, lastBotMessage, typingAnimationInProgress];
}

// Error state
class ChatbotError extends ChatbotState {
  final String error;
  final List<ChatMessage> existingMessages;

  const ChatbotError({
    required this.error,
    required this.existingMessages,
  }) : super(
    messages: existingMessages,
    isLoading: false,
    errorMessage: error,
    hasError: true,
  );

  @override
  List<Object?> get props => [error, existingMessages, hasError];
}

// Typing animation complete state
class ChatbotTypingComplete extends ChatbotState {
  final List<ChatMessage> completeMessages;

  const ChatbotTypingComplete({
    required this.completeMessages,
  }) : super(
    messages: completeMessages,
    isLoading: false,
    isTypingAnimationComplete: true,
  );

  @override
  List<Object?> get props => [completeMessages, isTypingAnimationComplete];
}