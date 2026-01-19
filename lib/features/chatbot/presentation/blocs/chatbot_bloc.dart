import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:coloncare/features/chatbot/domain/usecase/send_chat_message_usecase.dart';
import 'package:equatable/equatable.dart';

part 'chatbot_event.dart';
part 'chatbot_state.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final SendChatMessageUseCase sendChatMessageUseCase;
  Timer? _typingAnimationTimer;
  String? _currentBotMessageId;
  List<ChatMessage>? _currentMessagesForAnimation;

  ChatbotBloc({
    required this.sendChatMessageUseCase,
  }) : super(const ChatbotInitial()) {
    on<ChatbotMessageSent>(_onChatbotMessageSent);
    on<ChatbotMessageCleared>(_onChatbotMessageCleared);
    on<ChatbotConversationStarted>(_onChatbotConversationStarted);
    on<ChatbotErrorCleared>(_onChatbotErrorCleared);
    on<_UpdateTypingAnimation>(_onUpdateTypingAnimation);
    on<_CompleteTypingAnimation>(_onCompleteTypingAnimation);
  }

  Future<void> _onChatbotMessageSent(
      ChatbotMessageSent event,
      Emitter<ChatbotState> emit,
      ) async {
    // Add user message immediately
    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: event.message.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      animationKey: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    final messagesWithUser = List<ChatMessage>.from(state.messages)..add(userMessage);

    // Start loading state
    emit(ChatbotLoading(existingMessages: messagesWithUser));

    try {
      // Send to API
      final result = await sendChatMessageUseCase(event.message.trim());

      await result.fold(
            (failure) async {
          // Error state
          emit(ChatbotError(
            error: failure.message,
            existingMessages: messagesWithUser,
          ));
        },
            (chatResponse) async {
          // Add bot message with empty content initially (for typing animation)
          final botMessageId = 'bot_${DateTime.now().millisecondsSinceEpoch}';
          final botMessage = ChatMessage(
            id: botMessageId,
            content: '', // Start with empty content
            isUser: false,
            timestamp: DateTime.now(),
            animationKey: DateTime.now().millisecondsSinceEpoch.toString(),
          );

          final allMessages = List<ChatMessage>.from(messagesWithUser)..add(botMessage);

          // Store for animation
          _currentBotMessageId = botMessageId;
          _currentMessagesForAnimation = allMessages;

          // Start with empty message for typing animation
          emit(ChatbotLoaded(
            allMessages: allMessages,
            lastBotMessage: botMessage,
            typingAnimationInProgress: true,
          ));

          // Start typing animation
          _startTypingAnimation(fullText: chatResponse.reply);
        },
      );
    } catch (e) {
      emit(ChatbotError(
        error: 'Failed to send message: ${e.toString()}',
        existingMessages: messagesWithUser,
      ));
    }
  }

  void _startTypingAnimation({required String fullText}) {
    // Cancel any existing timer
    _typingAnimationTimer?.cancel();

    int currentIndex = 0;
    const typingSpeed = 30; // milliseconds per character

    _typingAnimationTimer = Timer.periodic(
      Duration(milliseconds: typingSpeed),
          (timer) {
        if (currentIndex < fullText.length && _currentBotMessageId != null && _currentMessagesForAnimation != null) {
          final partialText = fullText.substring(0, currentIndex + 1);

          // Add event to update animation
          add(_UpdateTypingAnimation(
            botMessageId: _currentBotMessageId!,
            currentText: partialText,
            isComplete: false,
          ));

          currentIndex++;
        } else {
          // Animation complete
          timer.cancel();

          if (_currentBotMessageId != null) {
            add(_CompleteTypingAnimation(
              botMessageId: _currentBotMessageId!,
              fullText: fullText,
            ));
          }

          // Clean up
          _currentBotMessageId = null;
          _currentMessagesForAnimation = null;
        }
      },
    );
  }

  void _onUpdateTypingAnimation(
      _UpdateTypingAnimation event,
      Emitter<ChatbotState> emit,
      ) {
    if (state is! ChatbotLoaded) return;

    final currentState = state as ChatbotLoaded;

    // Update the bot message with partial text
    final updatedMessages = currentState.allMessages.map((message) {
      if (message.id == event.botMessageId) {
        return message.copyWith(
          content: event.currentText,
          animationKey: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }
      return message;
    }).toList();

    // Find the updated bot message
    final updatedBotMessage = updatedMessages.firstWhere(
          (m) => m.id == event.botMessageId,
      orElse: () => currentState.lastBotMessage,
    );

    // Emit updated state
    emit(ChatbotLoaded(
      allMessages: updatedMessages,
      lastBotMessage: updatedBotMessage,
      typingAnimationInProgress: !event.isComplete,
    ));
  }

  void _onCompleteTypingAnimation(
      _CompleteTypingAnimation event,
      Emitter<ChatbotState> emit,
      ) {
    if (state is! ChatbotLoaded) return;

    final currentState = state as ChatbotLoaded;

    // Update the bot message with full text
    final finalMessages = currentState.allMessages.map((message) {
      if (message.id == event.botMessageId) {
        return message.copyWith(
          content: event.fullText,
          animationKey: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }
      return message;
    }).toList();

    // Emit final state
    emit(ChatbotTypingComplete(
      completeMessages: finalMessages,
    ));
  }

  void _onChatbotMessageCleared(
      ChatbotMessageCleared event,
      Emitter<ChatbotState> emit,
      ) {
    // Cancel any running animation
    _typingAnimationTimer?.cancel();
    _currentBotMessageId = null;
    _currentMessagesForAnimation = null;

    emit(const ChatbotInitial());
  }

  void _onChatbotConversationStarted(
      ChatbotConversationStarted event,
      Emitter<ChatbotState> emit,
      ) {
    // Cancel any running animation
    _typingAnimationTimer?.cancel();
    _currentBotMessageId = null;
    _currentMessagesForAnimation = null;

    // Add welcome message if empty
    if (state.messages.isEmpty) {
      final welcomeMessage = ChatMessage(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        content: 'Hello! I\'m your Colon Care assistant. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
        animationKey: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      emit(ChatbotLoaded(
        allMessages: [welcomeMessage],
        lastBotMessage: welcomeMessage,
        typingAnimationInProgress: false,
      ));
    }
  }

  void _onChatbotErrorCleared(
      ChatbotErrorCleared event,
      Emitter<ChatbotState> emit,
      ) {
    // Cancel any running animation
    _typingAnimationTimer?.cancel();
    _currentBotMessageId = null;
    _currentMessagesForAnimation = null;

    if (state is ChatbotError) {
      final errorState = state as ChatbotError;

      // Find last bot message or create empty one
      ChatMessage lastBotMessage = ChatMessage(
        id: 'empty',
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
      );

      if (errorState.existingMessages.isNotEmpty) {
        final lastMessage = errorState.existingMessages.last;
        if (!lastMessage.isUser) {
          lastBotMessage = lastMessage;
        }
      }

      emit(ChatbotLoaded(
        allMessages: errorState.existingMessages,
        lastBotMessage: lastBotMessage,
        typingAnimationInProgress: false,
      ));
    }
  }

  @override
  Future<void> close() {
    _typingAnimationTimer?.cancel();
    _currentBotMessageId = null;
    _currentMessagesForAnimation = null;
    return super.close();
  }
}

// Internal events for typing animation
class _UpdateTypingAnimation extends ChatbotEvent {
  final String botMessageId;
  final String currentText;
  final bool isComplete;

  const _UpdateTypingAnimation({
    required this.botMessageId,
    required this.currentText,
    this.isComplete = false,
  });

  @override
  List<Object> get props => [botMessageId, currentText, isComplete];
}

class _CompleteTypingAnimation extends ChatbotEvent {
  final String botMessageId;
  final String fullText;

  const _CompleteTypingAnimation({
    required this.botMessageId,
    required this.fullText,
  });

  @override
  List<Object> get props => [botMessageId, fullText];
}