class Message {
  final String id;
  final String reportId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isAdmin;

  Message({
    required this.id,
    required this.reportId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isAdmin,
  });
}
