import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/features/notifications/domain/entities/notification.dart';

class NotificationDTO {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final String? relatedId;

  NotificationDTO({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.relatedId,
  });

  factory NotificationDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationDTO(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'system',
      relatedId: data['relatedId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'relatedId': relatedId,
    };
  }

  AppNotification toDomain() {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead,
      type: NotificationType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => NotificationType.system,
      ),
      relatedId: relatedId,
    );
  }
}
