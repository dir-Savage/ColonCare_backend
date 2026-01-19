import 'package:coloncare/core/failures/failure.dart';
import 'package:coloncare/features/chatbot/data/datasources/chatbot_local_data_source.dart';
import 'package:coloncare/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:coloncare/features/chatbot/domain/entities/chat_response.dart';
import 'package:coloncare/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:coloncare/features/chatbot/domain/usecase/chatbot_failure.dart';
import 'package:dartz/dartz.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;
  final ChatbotLocalDataSource localDataSource;

  ChatbotRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ChatResponse>> sendMessage(String message) async {
    try {
      final response = await remoteDataSource.sendMessage(message);
      return Right(response);
    } catch (e) {
      return Left(ChatbotApiFailed(e.toString()));
    }
  }
}