import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/core/utils/app_animations.dart';
import 'package:coloncare/features/chatbot/presentation/blocs/chatbot_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatWelcomeWidget extends StatelessWidget {
  const ChatWelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildWelcomeIllustration(),
            const SizedBox(height: 40),
            _buildWelcomeText(),
            const SizedBox(height: 32),
            _buildExampleQuestions(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeIllustration() {
    return ScaleAnimation(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.smart_toy,
          size: 80,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        FadeInText(
          'Hi there! 👋',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        FadeInText(
          'I\'m your Colon Care AI Assistant',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        FadeInText(
          'I can help answer your questions about colon health, symptoms, and prevention.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildExampleQuestions(BuildContext context) {
    final exampleQuestions = [
      'What are the early signs of colon cancer?',
      'How can I prevent colon polyps?',
      'What foods are good for colon health?',
      'Explain what adenocarcinoma is',
      'When should I get a colonoscopy?',
    ];

    return Column(
      children: [
        FadeInText(
          'Try asking:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        ...exampleQuestions.map((question) {
          final index = exampleQuestions.indexOf(question);
          return SlideInAnimation(
            delay: Duration(milliseconds: 200 + (index * 100)),
            child: _buildQuestionChip(question, context),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionChip(String question, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<ChatbotBloc>().add(ChatbotMessageSent(question));
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange[400],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}