import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/features/chat/data/models/message_dto.dart';

class ChatRemoteDatasource {
  final FirebaseFirestore _firestore;

  ChatRemoteDatasource(this._firestore);

  Stream<List<MessageDTO>> getMessages(String reportId) {
    return _firestore
        .collection('reports')
        .doc(reportId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageDTO.fromFirestore(doc)).toList());
  }

  Future<void> sendMessage(MessageDTO message) async {
    await _firestore
        .collection('reports')
        .doc(message.reportId)
        .collection('messages')
        .add(message.toFirestore());
    
    // Update report's lastUpdatedAt
    await _firestore.collection('reports').doc(message.reportId).update({
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}
