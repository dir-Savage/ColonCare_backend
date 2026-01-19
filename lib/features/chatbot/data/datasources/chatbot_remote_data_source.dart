import 'dart:convert';
import 'package:coloncare/features/chatbot/data/models/chat_request_model.dart';
import 'package:coloncare/features/chatbot/data/models/chat_response_model.dart';
import 'package:coloncare/features/chatbot/domain/usecase/chatbot_failure.dart';
import 'package:http/http.dart' as http;

abstract class ChatbotRemoteDataSource {
  Future<ChatResponseModel> sendMessage(String message);
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final http.Client httpClient;

  static const String _apiBaseUrl = 'https://1b41e9a87d1c.ngrok-free.app/chat';

  ChatbotRemoteDataSourceImpl({
    required this.httpClient,
  });

  @override
  Future<ChatResponseModel> sendMessage(String message) async {
    try {
      final request = ChatRequestModel(message: message);

      final response = await httpClient.post(
        Uri.parse(_apiBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw ChatbotApiFailed(
          'Chatbot API failed (${response.statusCode}): ${response.body}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ChatResponseModel.fromJson(json);
    } catch (e) {
      if (e is ChatbotApiFailed) rethrow;
      throw ChatbotApiFailed('Failed to reach chatbot server: $e');
    }
  }
}