import 'package:coloncare/core/failures/failure.dart';

abstract class ChatbotFailure extends Failure {
  const ChatbotFailure(super.message);
}

class ChatbotApiFailed extends ChatbotFailure {
  const ChatbotApiFailed(super.message);
}

class ChatbotNetworkError extends ChatbotFailure {
  const ChatbotNetworkError() : super('Network error occurred');
}

class InvalidChatbotResponse extends ChatbotFailure {
  const InvalidChatbotResponse() : super('Invalid response from chatbot');
}