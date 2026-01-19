// features/chatbot/presentation/blocs/chat_animations_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'chat_animations_event.dart';
part 'chat_animations_state.dart';

class ChatAnimationsBloc extends Bloc<ChatAnimationsEvent, ChatAnimationsState> {
  ChatAnimationsBloc() : super(const ChatAnimationsInitial()) {
    on<MessageAdded>(_onMessageAdded);
    on<MessageBubbleAnimated>(_onMessageBubbleAnimated);
    on<MessageTypingStarted>(_onMessageTypingStarted);
    on<MessageTypingComplete>(_onMessageTypingComplete);
    on<AllAnimationsComplete>(_onAllAnimationsComplete);
    on<ResetAnimations>(_onResetAnimations);
  }

  void _onMessageAdded(
      MessageAdded event,
      Emitter<ChatAnimationsState> emit,
      ) {
    if (state is ChatAnimationsInitial) {
      emit(ChatAnimationsLoading(
        messageId: event.messageId,
        isUser: event.isUser,
      ));
    } else if (state is ChatAnimationsLoaded) {
      final currentState = state as ChatAnimationsLoaded;
      emit(currentState.copyWith(
        animatedMessages: {
          ...currentState.animatedMessages,
          event.messageId: AnimationStatus.pending,
        },
        lastMessageId: event.messageId,
      ));
    }
  }

  void _onMessageBubbleAnimated(
      MessageBubbleAnimated event,
      Emitter<ChatAnimationsState> emit,
      ) {
    if (state is ChatAnimationsLoaded) {
      final currentState = state as ChatAnimationsLoaded;
      emit(currentState.copyWith(
        animatedMessages: {
          ...currentState.animatedMessages,
          event.messageId: AnimationStatus.bubbleComplete,
        },
      ));
    }
  }

  void _onMessageTypingStarted(
      MessageTypingStarted event,
      Emitter<ChatAnimationsState> emit,
      ) {
    if (state is ChatAnimationsLoaded) {
      final currentState = state as ChatAnimationsLoaded;
      emit(currentState.copyWith(
        typingMessageId: event.messageId,
        isTypingInProgress: true,
        typingProgress: 0.0,
      ));
    }
  }

  void _onMessageTypingComplete(
      MessageTypingComplete event,
      Emitter<ChatAnimationsState> emit,
      ) {
    if (state is ChatAnimationsLoaded) {
      final currentState = state as ChatAnimationsLoaded;
      emit(currentState.copyWith(
        animatedMessages: {
          ...currentState.animatedMessages,
          event.messageId: AnimationStatus.complete,
        },
        typingMessageId: null,
        isTypingInProgress: false,
        typingProgress: 1.0,
      ));
    }
  }

  void _onAllAnimationsComplete(
      AllAnimationsComplete event,
      Emitter<ChatAnimationsState> emit,
      ) {
    emit(const ChatAnimationsComplete());
  }

  void _onResetAnimations(
      ResetAnimations event,
      Emitter<ChatAnimationsState> emit,
      ) {
    emit(const ChatAnimationsInitial());
  }
}