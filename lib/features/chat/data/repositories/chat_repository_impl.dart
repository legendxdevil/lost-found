import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/features/chat/domain/entities/message.dart';
import 'package:lost_and_found/features/chat/domain/repositories/chat_repository.dart';
import 'package:lost_and_found/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lost_and_found/features/chat/data/models/message_dto.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _remoteDatasource;

  ChatRepositoryImpl(this._remoteDatasource);

  @override
  Stream<List<Message>> getMessages(String reportId) {
    return _remoteDatasource.getMessages(reportId).map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
        );
  }

  @override
  Future<Either<Failure, Unit>> sendMessage(Message message) async {
    try {
      await _remoteDatasource.sendMessage(MessageDTO.fromDomain(message));
      return right(unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
