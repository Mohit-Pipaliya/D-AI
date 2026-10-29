import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

/// Implementation of [ChatRepository] integrating remote datasource with in-memory cache.
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;
  final Map<String, List<Message>> _memoryCache = {};

  @override
  Stream<String> streamMessage({
    required String conversationId,
    required String prompt,
    List<Message> history = const [],
  }) {
    return _remoteDataSource.streamChat(
      conversationId: conversationId,
      prompt: prompt,
      history: history,
    );
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    return List.unmodifiable(_memoryCache[conversationId] ?? []);
  }

  @override
  Future<void> saveMessage(String conversationId, Message message) async {
    final list = _memoryCache.putIfAbsent(conversationId, () => []);
    final existingIndex = list.indexWhere((m) => m.id == message.id);
    if (existingIndex >= 0) {
      list[existingIndex] = message;
    } else {
      list.add(message);
    }
  }
}

