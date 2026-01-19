import 'package:coloncare/features/chatbot/domain/entities/chat_response.dart';
import 'package:dartz/dartz.dart';
import 'package:coloncare/core/failures/failure.dart';

abstract class ChatbotRepository {
  /// Sends a message to the chatbot API and returns the response
  Future<Either<Failure, ChatResponse>> sendMessage(String message);
}