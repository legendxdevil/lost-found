import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/features/chat/domain/entities/message.dart';
import 'package:lost_and_found/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, Unit>> call(Message message) async {
    return await _repository.sendMessage(message);
  }
}
