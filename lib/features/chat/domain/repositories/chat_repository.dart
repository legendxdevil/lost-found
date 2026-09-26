import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  Stream<List<Message>> getMessages(String reportId);
  Future<Either<Failure, Unit>> sendMessage(Message message);
}
