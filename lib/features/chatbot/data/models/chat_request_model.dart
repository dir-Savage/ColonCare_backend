class ChatRequestModel {
  final String message;

  ChatRequestModel({
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}