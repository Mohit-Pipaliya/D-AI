import 'dart:convert';

import '../../../../core/network/sse_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/message.dart';

/// Contract for backend chat streaming via Server-Sent Events.
abstract interface class ChatRemoteDataSource {
  Stream<String> streamChat({
    required String conversationId,
    required String prompt,
    List<Message> history = const [],
  });
}

/// Implementation of [ChatRemoteDataSource] using [SseClient].
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl(this._sseClient);

  final SseClient _sseClient;

  @override
  Stream<String> streamChat({
    required String conversationId,
    required String prompt,
    List<Message> history = const [],
  }) async* {
    AppLogger.d('Starting chat stream for conv=$conversationId');

    final payload = {
      'conversation_id': conversationId,
      'prompt': prompt,
      'history': history
          .map((m) => {
                'role': m.role.name,
                'content': m.content,
              })
          .toList(),
    };

    final eventStream = _sseClient.connect(
      path: '/api/v1/chat/stream',
      data: payload,
    );

    await for (final event in eventStream) {
      if (event.event == 'done' || event.data == '[DONE]') {
        break;
      }

      if (event.event == 'token' || event.event == 'message') {
        try {
          final decoded = jsonDecode(event.data);
          if (decoded is Map<String, dynamic> && decoded.containsKey('token')) {
            yield decoded['token'] as String;
          } else {
            yield event.data;
          }
        } catch (_) {
          yield event.data;
        }
      }
    }
  }
}
