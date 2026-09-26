import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/features/notifications/data/models/notification_dto.dart';

class NotificationRemoteDatasource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDatasource(this._firestore);

  Stream<List<NotificationDTO>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => NotificationDTO.fromFirestore(doc))
              .toList();
          // Sort in memory to avoid needing a composite index
          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return notifications;
        });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> sendNotification(NotificationDTO notification) async {
    await _firestore.collection('notifications').add(notification.toFirestore());
  }
}
