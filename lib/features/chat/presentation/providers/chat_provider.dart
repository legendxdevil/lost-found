import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/features/chat/domain/entities/message.dart';
import 'package:lost_and_found/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lost_and_found/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:lost_and_found/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lost_and_found/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:lost_and_found/features/auth/presentation/providers/auth_provider.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRemoteDatasource chatRemoteDatasource(ChatRemoteDatasourceRef ref) {
  return ChatRemoteDatasource(FirebaseFirestore.instance);
}

@riverpod
ChatRepositoryImpl chatRepository(ChatRepositoryRef ref) {
  return ChatRepositoryImpl(ref.watch(chatRemoteDatasourceProvider));
}

@riverpod
SendMessageUseCase sendMessageUseCase(SendMessageUseCaseRef ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
}

@riverpod
GetMessagesUseCase getMessagesUseCase(GetMessagesUseCaseRef ref) {
  return GetMessagesUseCase(ref.watch(chatRepositoryProvider));
}

@riverpod
Stream<List<Message>> chatMessages(ChatMessagesRef ref, String reportId) {
  return ref.watch(getMessagesUseCaseProvider).call(reportId);
}

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> sendMessage({
    required String reportId,
    required String text,
  }) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    final isAdmin = ref.read(isAdminProvider).valueOrNull ?? false;
    
    if (user == null) return;

    final message = Message(
      id: '', // Firestore will assign
      reportId: reportId,
      senderId: user.uid,
      senderName: user.name,
      text: text,
      timestamp: DateTime.now(),
      isAdmin: isAdmin,
    );

    state = const AsyncLoading();
    final result = await ref.read(sendMessageUseCaseProvider).call(message);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
