import 'package:coloncare/core/utils/app_animations.dart';
import 'package:coloncare/features/chatbot/presentation/blocs/chatbot_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isFirstInSequence;
  final bool isLastInSequence;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    this.isFirstInSequence = true,
    this.isLastInSequence = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) _buildBotAvatar(),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (isFirstInSequence) const SizedBox(height: 8),
                _buildMessageBubble(context),
                if (isLastInSequence) const SizedBox(height: 4),
              ],
            ),
          ),
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: const Icon(
          Icons.smart_toy,
          size: 18,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.green.withOpacity(0.1),
        child: const Icon(
          Icons.person,
          size: 18,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(message.isUser ? 16 : 4),
      topRight: Radius.circular(message.isUser ? 4 : 16),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );

    return FadeInAnimation(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[100],
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: _buildMessageContent(),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    return BlocBuilder<ChatbotBloc, ChatbotState>(
      buildWhen: (previous, current) {
        if (current is ChatbotLoaded || current is ChatbotTypingComplete) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        final isTyping = state is ChatbotLoaded &&
            state.typingAnimationInProgress &&
            state.lastBotMessage.id == message.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isTyping && message.content.isEmpty)
              _buildTypingIndicator()
            else
              _buildMessageText(),
            if (message.isUser)
              _buildMessageTimestamp(),
          ],
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      width: 60,
      height: 30,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTypingDot(0),
          const SizedBox(width: 4),
          _buildTypingDot(1),
          const SizedBox(width: 4),
          _buildTypingDot(2),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return ScaleAnimation(
      duration: Duration(milliseconds: 600 + (index * 200)),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildMessageText() {
    return SlideInAnimation(
      delay: const Duration(milliseconds: 100),
      child: SelectableText(
        message.content,
        style: TextStyle(
          fontSize: 16,
          color: message.isUser ? Colors.white : Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildMessageTimestamp() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        _formatTime(message.timestamp),
        style: TextStyle(
          fontSize: 11,
          color: message.isUser ? Colors.white70 : Colors.grey[600],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}