import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/features/chat/domain/entities/message.dart';

class MessageDTO {
  final String id;
  final String reportId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isAdmin;

  MessageDTO({
    required this.id,
    required this.reportId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isAdmin,
  });

  factory MessageDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageDTO(
      id: doc.id,
      reportId: data['reportId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reportId': reportId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAdmin': isAdmin,
    };
  }

  Message toDomain() {
    return Message(
      id: id,
      reportId: reportId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: timestamp,
      isAdmin: isAdmin,
    );
  }

  factory MessageDTO.fromDomain(Message message) {
    return MessageDTO(
      id: message.id,
      reportId: message.reportId,
      senderId: message.senderId,
      senderName: message.senderName,
      text: message.text,
      timestamp: message.timestamp,
      isAdmin: message.isAdmin,
    );
  }
}
