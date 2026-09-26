import 'package:lost_and_found/features/chat/domain/entities/message.dart';
import 'package:lost_and_found/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository _repository;

  GetMessagesUseCase(this._repository);

  Stream<List<Message>> call(String reportId) {
    return _repository.getMessages(reportId);
  }
}
