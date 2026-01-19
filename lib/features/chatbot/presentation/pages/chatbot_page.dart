import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/features/chatbot/presentation/blocs/animations_bloc/chat_animations_bloc.dart';
import 'package:coloncare/features/chatbot/presentation/blocs/chatbot_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injector.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_welcome.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatbotBloc>(
          create: (_) => getIt<ChatbotBloc>(),
        ),
        BlocProvider<ChatAnimationsBloc>(
          create: (_) => ChatAnimationsBloc(),
        ),
      ],
      child: const _ChatbotPageContent(),
    );
  }
}

class _ChatbotPageContent extends StatelessWidget {
  const _ChatbotPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatbotBloc, ChatbotState>(
      listener: (context, state) {
        if (state is ChatbotInitial) {
          context.read<ChatAnimationsBloc>().add(ResetAnimations());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Colon Care'),
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Image(
              image: const AssetImage(AssetsManager.appLogo),
              fit: BoxFit.contain,
              height: 50,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  backgroundColor:
                  Colors.blue,
                  child: ClipOval(
                    child: SvgPicture.network(
                      AssetsManager.avatarUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildChatContent(context),
            ),
            const ChatInputWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent(BuildContext context) {
    return BlocBuilder<ChatbotBloc, ChatbotState>(
      builder: (context, state) {
        if (state.showWelcomeMessage) {
          return const ChatWelcomeWidget();
        }

        if (state.isLoading && state.messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError && state.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'An error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ChatbotBloc>().add(ChatbotErrorCleared());
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        return _buildChatMessages(context, state.messages);
      },
    );
  }

  Widget _buildChatMessages(BuildContext context, List<ChatMessage> messages) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      reverse: true,
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: 20);
        }

        final messageIndex = messages.length - index;
        final message = messages[messageIndex];

        return ChatBubbleWidget(
          message: message,
          isFirstInSequence: messageIndex == 0 ||
              messages[messageIndex - 1].isUser != message.isUser,
          isLastInSequence: messageIndex == messages.length - 1 ||
              messages[messageIndex + 1].isUser != message.isUser,
        );
      },
    );
  }
}