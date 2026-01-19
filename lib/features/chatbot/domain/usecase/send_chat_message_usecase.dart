import 'package:coloncare/features/chatbot/domain/entities/chat_response.dart';
import 'package:coloncare/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

class SendChatMessageUseCase {
  final ChatbotRepository repository;

  SendChatMessageUseCase(this.repository);

  Future<Either<Failure, ChatResponse>> call(String message) {
    return repository.sendMessage(message);
  }
}