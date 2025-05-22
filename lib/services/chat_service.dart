import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Message>> getMessages(String currentUserId, String otherUserId) {
    final chatId = _getChatId(currentUserId, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    });
  }

  Future<void> sendMessage(
    String senderId,
    String receiverId,
    String content,
  ) async {
    final chatId = _getChatId(senderId, receiverId);
    final messageId = _firestore.collection('chats').doc().id;

    final message = Message(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  String _getChatId(String userId1, String userId2) {
    // Sort the user IDs to ensure consistent chat ID regardless of who initiates
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}
