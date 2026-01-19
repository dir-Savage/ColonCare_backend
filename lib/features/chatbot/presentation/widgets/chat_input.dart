import 'package:coloncare/core/utils/app_animations.dart';
import 'package:coloncare/features/chatbot/presentation/blocs/chatbot_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatInputWidget extends StatefulWidget {
  const ChatInputWidget({super.key});

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatbotBloc, ChatbotState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTextField(context, state),
              ),
              const SizedBox(width: 12),
              _buildSendButton(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context, ChatbotState state) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      maxLines: 4,
      minLines: 1,
      enabled: !state.isLoading,
      decoration: InputDecoration(
        hintText: 'Type your message...',
        hintStyle: TextStyle(
          color: Colors.grey[500],
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearInput,
          color: Colors.grey[500],
        )
            : null,
      ),
      onChanged: (value) {
        setState(() {});
      },
      onSubmitted: (value) {
        if (value.trim().isNotEmpty && !state.isLoading) {
          _sendMessage(value.trim());
        }
      },
    );
  }

  Widget _buildSendButton(BuildContext context, ChatbotState state) {
    final isEnabled = _controller.text.trim().isNotEmpty && !state.isLoading;

    return ScaleAnimation(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isEnabled
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          )
              : null,
          color: !isEnabled ? Colors.grey[300] : null,
          boxShadow: isEnabled
              ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: isEnabled
                ? () => _sendMessage(_controller.text.trim())
                : null,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(14),
              child: state.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.isEmpty) return;

    context.read<ChatbotBloc>().add(ChatbotMessageSent(message));
    _clearInput();
    _focusNode.unfocus();
  }

  void _clearInput() {
    _controller.clear();
    setState(() {});
  }
}