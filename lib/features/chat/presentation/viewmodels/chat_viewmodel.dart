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
    this.errorMessage,
  });

  final List<Message> messages;
  final bool isLoading;
  final String? errorMessage;

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, errorMessage];
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

  /// Sends a message and streams the assistant response.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    const uuid = Uuid();
    final userMessage = Message(
      id: uuid.v4(),
      role: MessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    final assistantMessageId = uuid.v4();
    final initialAssistantMessage = Message(
      id: assistantMessageId,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      status: MessageStatus.streaming,
    );

    final updatedMessages = [
      ...state.messages,
      userMessage,
      initialAssistantMessage,
    ];

    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      errorMessage: null,
    );

    await _chatRepository.saveMessage(_conversationId, userMessage);

    var assistantContent = '';

    _streamSub?.cancel();
    _streamSub = _chatRepository
        .streamMessage(
      conversationId: _conversationId,
      prompt: trimmed,
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
        _updateAssistantMessage(
          assistantMessageId,
          assistantContent.isEmpty
              ? 'Failed to get response.'
              : assistantContent,
          MessageStatus.error,
          errorMessage: error.toString(),
        );
        state = state.copyWith(isLoading: false);
      },
      onDone: () {
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
