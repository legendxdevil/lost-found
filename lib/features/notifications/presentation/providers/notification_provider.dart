import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/features/notifications/domain/entities/notification.dart';
import 'package:lost_and_found/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:lost_and_found/features/auth/presentation/providers/auth_provider.dart';

part 'notification_provider.g.dart';

@riverpod
NotificationRemoteDatasource notificationDatasource(NotificationDatasourceRef ref) {
  return NotificationRemoteDatasource(FirebaseFirestore.instance);
}

@riverpod
Stream<List<AppNotification>> myNotifications(MyNotificationsRef ref) {
  final userId = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (userId == null) return Stream.value([]);
  
  return ref.watch(notificationDatasourceProvider).getNotifications(userId).map(
        (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
      );
}

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> markAsRead(String notificationId) async {
    await ref.read(notificationDatasourceProvider).markAsRead(notificationId);
  }
}
