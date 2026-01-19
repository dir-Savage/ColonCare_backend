import 'package:equatable/equatable.dart';

class ChatResponse extends Equatable {
  final String reply;

  const ChatResponse({
    required this.reply,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      reply: json['reply'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reply': reply,
    };
  }

  @override
  List<Object> get props => [reply];
}