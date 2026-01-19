import 'package:coloncare/features/chatbot/domain/entities/chat_response.dart';

class ChatResponseModel extends ChatResponse {
  const ChatResponseModel({
    required super.reply,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      reply: json['reply'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'reply': reply,
    };
  }
}