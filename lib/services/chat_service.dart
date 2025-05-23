import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/chat_models.dart';

class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Singleton instance
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // Mock chat data storage
  final Map<String, List<Message>> _chats = {};

  // Mock message controllers for streams
  final Map<String, StreamController<List<Message>>> _controllers = {};

  // Send a new message
  Future<void> sendMessage(Message message) async {
    final chatId = _getChatId(message.senderId, message.receiverId);
    await _database
        .child('chats')
        .child(chatId)
        .child('messages')
        .child(message.id)
        .set(message.toMap());

    // Update latest message for both users
    await _updateLatestMessage(message.senderId, message.receiverId, message);
  }

  // Get all messages for a chat
  Stream<List<Message>> getMessages(String currentUserId, String otherUserId) {
    final chatId = _getChatId(currentUserId, otherUserId);
    return _database
        .child('chats')
        .child(chatId)
        .child('messages')
        .onValue
        .map((event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      final messages = data.values
          .map((messageData) =>
              Message.fromMap(Map<String, dynamic>.from(messageData)))
          .toList();

      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    });
  }

  // Get all chats for a user
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _database
        .child('users')
        .child(userId)
        .child('chats')
        .onValue
        .map((event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.values.map((chatData) {
        return Map<String, dynamic>.from(chatData);
      }).toList()
        ..sort((a, b) => (b['timestamp'] as int? ?? 0)
            .compareTo(a['timestamp'] as int? ?? 0));
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
      String currentUserId, String otherUserId) async {
    final chatId = _getChatId(currentUserId, otherUserId);
    final messagesRef =
        _database.child('chats').child(chatId).child('messages');

    final DataSnapshot snapshot = await messagesRef.get();
    final Map<dynamic, dynamic>? messages =
        snapshot.value as Map<dynamic, dynamic>?;

    if (messages != null) {
      final updates = <String, dynamic>{};
      messages.forEach((key, value) {
        if (value['receiverId'] == currentUserId &&
            !(value['isRead'] as bool? ?? false)) {
          updates['$key/isRead'] = true;
        }
      });

      if (updates.isNotEmpty) {
        await messagesRef.update(updates);
      }
    }
  }

  // Helper method to generate a consistent chat ID
  String _getChatId(String userId1, String userId2) {
    final List<String> ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Update latest message in users' chat lists
  Future<void> _updateLatestMessage(
      String senderId, String receiverId, Message message) async {
    final latestMessageData = {
      'lastMessage': message.content,
      'timestamp': message.timestamp.millisecondsSinceEpoch,
      'unreadCount': ServerValue.increment(1),
      'otherUserId': receiverId,
    };

    // Update sender's chat list
    await _database
        .child('users')
        .child(senderId)
        .child('chats')
        .child(receiverId)
        .update(latestMessageData);

    // Update receiver's chat list
    latestMessageData['otherUserId'] = senderId;
    await _database
        .child('users')
        .child(receiverId)
        .child('chats')
        .child(senderId)
        .update(latestMessageData);
  }
}
