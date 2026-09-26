enum NotificationType { statusUpdate, message, system }

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? relatedId; // e.g. reportId or chatId

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.relatedId,
  });
}
