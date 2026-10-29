import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

/// State of the Chat ViewModel.
class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isOffline = false,
    this.errorMessage,
  });

  final List<Message> messages;
  final bool isLoading;
  final bool isOffline;
  final String? errorMessage;

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isOffline,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, isOffline, errorMessage];
}

/// Provider for the [ChatRemoteDataSource].
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final sse = ref.watch(sseClientProvider);
  return ChatRemoteDataSourceImpl(sse);
});

/// Provider for the [ChatRepository].
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remote = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remote);
});

/// Riverpod StateNotifier managing the conversation and streaming responses.
class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel({
    required ChatRepository chatRepository,
    String conversationId = 'default',
  })  : _chatRepository = chatRepository,
        _conversationId = conversationId,
        super(const ChatState());

  final ChatRepository _chatRepository;
  final String _conversationId;
  StreamSubscription<String>? _streamSub;

  /// Sets offline connectivity mode manually or via connectivity listener.
  void setOffline(bool offline) {
    state = state.copyWith(isOffline: offline);
    if (!offline) {
      processQueuedMessages();
    }
  }

  /// Sends a user message and streams the assistant response.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    const uuid = Uuid();
    final userMessage = Message(
      id: uuid.v4(),
      role: MessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
      status: state.isOffline ? MessageStatus.queued : MessageStatus.sent,
    );

    // If offline, queue the message and do not trigger remote stream
    if (state.isOffline) {
      state = state.copyWith(
        messages: [...state.messages, userMessage],
      );
      await _chatRepository.saveMessage(_conversationId, userMessage);
      return;
    }

    final assistantMessageId = uuid.v4();
    final initialAssistantMessage = Message(
      id: assistantMessageId,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      status: MessageStatus.streaming,
    );

    state = state.copyWith(
      messages: [
        ...state.messages,
        userMessage,
        initialAssistantMessage,
      ],
      isLoading: true,
      errorMessage: null,
    );

    await _chatRepository.saveMessage(_conversationId, userMessage);

    _startStream(
      prompt: trimmed,
      assistantMessageId: assistantMessageId,
    );
  }

  /// Retries sending a message that previously failed or was queued.
  Future<void> retryMessage(String messageId) async {
    if (state.isLoading) return;

    final index = state.messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;

    final targetMessage = state.messages[index];
    String promptToResend;
    String assistantMessageId;

    if (targetMessage.role.isUser) {
      promptToResend = targetMessage.content;
      const uuid = Uuid();
      assistantMessageId = uuid.v4();
      final assistantMsg = Message(
        id: assistantMessageId,
        role: MessageRole.assistant,
        content: '',
        createdAt: DateTime.now(),
        status: MessageStatus.streaming,
      );

      final updated = [...state.messages];
      updated[index] = targetMessage.copyWith(status: MessageStatus.sent);
      state = state.copyWith(
        messages: [...updated, assistantMsg],
        isLoading: true,
        errorMessage: null,
      );
    } else {
      // It's a failed assistant message, find the preceding user message
      if (index > 0 && state.messages[index - 1].role.isUser) {
        promptToResend = state.messages[index - 1].content;
      } else {
        promptToResend = targetMessage.content;
      }
      assistantMessageId = targetMessage.id;
      final updated = [...state.messages];
      updated[index] = targetMessage.copyWith(
        content: '',
        status: MessageStatus.streaming,
        errorMessage: null,
      );
      state = state.copyWith(
        messages: updated,
        isLoading: true,
        errorMessage: null,
      );
    }

    _startStream(
      prompt: promptToResend,
      assistantMessageId: assistantMessageId,
    );
  }

  /// Resends all queued messages in order once network is available.
  Future<void> processQueuedMessages() async {
    final queued = state.messages.where((m) => m.status.isQueued).toList();
    for (final msg in queued) {
      await retryMessage(msg.id);
    }
  }

  void _startStream({
    required String prompt,
    required String assistantMessageId,
  }) {
    var assistantContent = '';
    var hasError = false;

    _streamSub?.cancel();
    _streamSub = _chatRepository
        .streamMessage(
      conversationId: _conversationId,
      prompt: prompt,
      history: state.messages,
    )
        .listen(
      (token) {
        assistantContent += token;
        _updateAssistantMessage(
          assistantMessageId,
          assistantContent,
          MessageStatus.streaming,
        );
      },
      onError: (Object error) {
        hasError = true;
        _updateAssistantMessage(
          assistantMessageId,
          assistantContent.isEmpty
              ? 'Network failure: Unable to reach D.'
              : assistantContent,
          MessageStatus.error,
          errorMessage: error.toString(),
        );
        state = state.copyWith(isLoading: false);
      },
      onDone: () {
        if (!hasError) {
          _updateAssistantMessage(
            assistantMessageId,
            assistantContent,
            MessageStatus.sent,
          );
          state = state.copyWith(isLoading: false);
          _chatRepository.saveMessage(
            _conversationId,
            Message(
              id: assistantMessageId,
              role: MessageRole.assistant,
              content: assistantContent,
              createdAt: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  void _updateAssistantMessage(
    String id,
    String content,
    MessageStatus status, {
    String? errorMessage,
  }) {
    final current = [...state.messages];
    final index = current.indexWhere((m) => m.id == id);
    if (index >= 0) {
      current[index] = current[index].copyWith(
        content: content,
        status: status,
        errorMessage: errorMessage,
      );
      state = state.copyWith(messages: current);
    }
  }

  /// Cancels an in-progress stream generation.
  void stopGeneration() {
    _streamSub?.cancel();
    _streamSub = null;
    state = state.copyWith(isLoading: false);
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}

/// Provider for the [ChatViewModel].
final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatViewModel(chatRepository: repository);
});
