import 'dart:async';
import '../models/chat_models.dart';

class ChatService {
  // Singleton instance
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // Mock chat data storage
  final Map<String, List<Message>> _chats = {};

  // Mock message controllers for streams
  final Map<String, StreamController<List<Message>>> _controllers = {};

  Stream<List<Message>> getMessages(String currentUserId, String otherUserId) {
    final chatId = _getChatId(currentUserId, otherUserId);

    // Create controller if it doesn't exist
    if (!_controllers.containsKey(chatId)) {
      _controllers[chatId] = StreamController<List<Message>>.broadcast();

      // Initialize with empty list if no messages exist
      if (!_chats.containsKey(chatId)) {
        _chats[chatId] = [];
      }

      // Add initial data
      _controllers[chatId]!.add(_chats[chatId]!);
    }

    return _controllers[chatId]!.stream;
  }

  Future<void> sendMessage(
    String senderId,
    String receiverId,
    String content,
  ) async {
    final chatId = _getChatId(senderId, receiverId);
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    final message = Message(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    // Initialize chat if it doesn't exist
    if (!_chats.containsKey(chatId)) {
      _chats[chatId] = [];
    }

    // Add message to chat
    _chats[chatId]!.insert(0, message);

    // Notify listeners if controller exists
    if (_controllers.containsKey(chatId)) {
      _controllers[chatId]!.add(_chats[chatId]!);
    }
  }

  String _getChatId(String userId1, String userId2) {
    // Sort the user IDs to ensure consistent chat ID regardless of who initiates
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}
