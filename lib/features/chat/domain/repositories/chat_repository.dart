import '../entities/message.dart';

/// Contract for chat persistence and LLM communication.
abstract interface class ChatRepository {
  /// Sends a user message and returns a stream of assistant token updates.
  Stream<String> streamMessage({
    required String conversationId,
    required String prompt,
    List<Message> history = const [],
  });

  /// Retrieves cached conversation message history.
  Future<List<Message>> getMessages(String conversationId);

  /// Saves a message locally.
  Future<void> saveMessage(String conversationId, Message message);
}
