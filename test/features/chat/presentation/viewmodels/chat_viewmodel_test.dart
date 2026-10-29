import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:d_ai/features/chat/domain/entities/message.dart';
import 'package:d_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:d_ai/features/chat/presentation/viewmodels/chat_viewmodel.dart';

class MockChatRepository implements ChatRepository {
  final List<Message> savedMessages = [];
  StreamController<String>? activeController;

  @override
  Stream<String> streamMessage({
    required String conversationId,
    required String prompt,
    List<Message> history = const [],
  }) {
    activeController = StreamController<String>();
    return activeController!.stream;
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    return savedMessages;
  }

  @override
  Future<void> saveMessage(String conversationId, Message message) async {
    savedMessages.add(message);
  }
}

void main() {
  group('ChatViewModel', () {
    late MockChatRepository repository;
    late ChatViewModel viewModel;

    setUp(() {
      repository = MockChatRepository();
      viewModel = ChatViewModel(chatRepository: repository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('initial state has empty messages and not loading', () {
      expect(viewModel.state.messages, isEmpty);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.isOffline, isFalse);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('sendMessage adds user message and initial assistant placeholder',
        () async {
      final future = viewModel.sendMessage('Hello D');
      await pumpEventQueue();

      // State should immediately have 2 messages (user + assistant streaming)
      expect(viewModel.state.messages.length, equals(2));
      expect(viewModel.state.messages[0].role, equals(MessageRole.user));
      expect(viewModel.state.messages[0].content, equals('Hello D'));
      expect(viewModel.state.messages[1].role, equals(MessageRole.assistant));
      expect(
          viewModel.state.messages[1].status, equals(MessageStatus.streaming));
      expect(viewModel.state.isLoading, isTrue);

      // Stream tokens
      repository.activeController?.add('Hi! ');
      await pumpEventQueue();
      expect(viewModel.state.messages[1].content, equals('Hi! '));

      repository.activeController?.add('How can I help?');
      await pumpEventQueue();
      expect(
          viewModel.state.messages[1].content, equals('Hi! How can I help?'));

      // Close stream
      await repository.activeController?.close();
      await future;

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.messages[1].status, equals(MessageStatus.sent));
    });

    test('stopGeneration cancels loading state', () async {
      unawaited(viewModel.sendMessage('Tell me a long story'));
      expect(viewModel.state.isLoading, isTrue);

      viewModel.stopGeneration();
      expect(viewModel.state.isLoading, isFalse);
    });

    test('offline mode queues user message without starting stream', () async {
      viewModel.setOffline(true);
      expect(viewModel.state.isOffline, isTrue);

      await viewModel.sendMessage('Queued offline question');
      await pumpEventQueue();

      // Only 1 message (user message in queued status), no assistant message added
      expect(viewModel.state.messages.length, equals(1));
      expect(viewModel.state.messages[0].content,
          equals('Queued offline question'));
      expect(viewModel.state.messages[0].status, equals(MessageStatus.queued));
      expect(viewModel.state.isLoading, isFalse);
      expect(repository.activeController, isNull);
    });

    test('retryMessage restarts stream for failed assistant message', () async {
      // Send a message that fails
      final future = viewModel.sendMessage('Test prompt');
      await pumpEventQueue();

      repository.activeController?.addError(Exception('Network timeout'));
      await repository.activeController?.close();
      await future;

      expect(viewModel.state.messages[1].status, equals(MessageStatus.error));

      // Retry the assistant message
      final retryFuture =
          viewModel.retryMessage(viewModel.state.messages[1].id);
      await pumpEventQueue();

      expect(viewModel.state.isLoading, isTrue);
      expect(
          viewModel.state.messages[1].status, equals(MessageStatus.streaming));

      repository.activeController?.add('Recovered answer');
      await pumpEventQueue();
      expect(viewModel.state.messages[1].content, equals('Recovered answer'));

      await repository.activeController?.close();
      await retryFuture;

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.messages[1].status, equals(MessageStatus.sent));
    });
  });
}
