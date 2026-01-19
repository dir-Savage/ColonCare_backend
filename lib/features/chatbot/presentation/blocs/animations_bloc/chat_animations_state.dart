part of 'chat_animations_bloc.dart';

enum AnimationStatus {
  pending,      // Message added but not animated yet
  bubbleComplete, // Bubble animation complete
  typingInProgress, // Typing animation in progress
  complete,     // All animations complete
}

class ChatAnimationsState extends Equatable {
  final Map<String, AnimationStatus> animatedMessages;
  final String? lastMessageId;
  final bool isTypingInProgress;
  final String? typingMessageId;
  final double typingProgress;

  const ChatAnimationsState({
    this.animatedMessages = const {},
    this.lastMessageId,
    this.isTypingInProgress = false,
    this.typingMessageId,
    this.typingProgress = 0.0,
  });

  bool isMessageAnimated(String messageId) {
    return animatedMessages[messageId] == AnimationStatus.complete ||
        animatedMessages[messageId] == AnimationStatus.bubbleComplete;
  }

  bool isMessageTyping(String messageId) {
    return animatedMessages[messageId] == AnimationStatus.typingInProgress;
  }

  bool shouldAnimateBubble(String messageId) {
    return animatedMessages[messageId] == AnimationStatus.pending;
  }

  @override
  List<Object?> get props => [
    animatedMessages,
    lastMessageId,
    isTypingInProgress,
    typingMessageId,
    typingProgress,
  ];
}

class ChatAnimationsInitial extends ChatAnimationsState {
  const ChatAnimationsInitial() : super();
}

class ChatAnimationsLoading extends ChatAnimationsState {
  final String messageId;
  final bool isUser;

  const ChatAnimationsLoading({
    required this.messageId,
    required this.isUser,
  }) : super(
    lastMessageId: messageId,
  );

  @override
  List<Object?> get props => [messageId, isUser, ...super.props];
}

class ChatAnimationsLoaded extends ChatAnimationsState {
  const ChatAnimationsLoaded({
    required Map<String, AnimationStatus> animatedMessages,
    String? lastMessageId,
    bool isTypingInProgress = false,
    String? typingMessageId,
    double typingProgress = 0.0,
  }) : super(
    animatedMessages: animatedMessages,
    lastMessageId: lastMessageId,
    isTypingInProgress: isTypingInProgress,
    typingMessageId: typingMessageId,
    typingProgress: typingProgress,
  );

  ChatAnimationsLoaded copyWith({
    Map<String, AnimationStatus>? animatedMessages,
    String? lastMessageId,
    bool? isTypingInProgress,
    String? typingMessageId,
    double? typingProgress,
  }) {
    return ChatAnimationsLoaded(
      animatedMessages: animatedMessages ?? this.animatedMessages,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      isTypingInProgress: isTypingInProgress ?? this.isTypingInProgress,
      typingMessageId: typingMessageId ?? this.typingMessageId,
      typingProgress: typingProgress ?? this.typingProgress,
    );
  }
}

class ChatAnimationsComplete extends ChatAnimationsState {
  const ChatAnimationsComplete() : super(
    isTypingInProgress: false,
    typingProgress: 1.0,
  );
}