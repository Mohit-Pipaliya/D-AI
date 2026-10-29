import 'package:equatable/equatable.dart';

/// Role of the message author.
enum MessageRole {
  user,
  assistant,
  system;

  bool get isUser => this == MessageRole.user;
  bool get isAssistant => this == MessageRole.assistant;
  bool get isSystem => this == MessageRole.system;
}

/// Delivery or streaming state of a chat message.
enum MessageStatus {
  sending,
  streaming,
  sent,
  error;

  bool get isStreaming => this == MessageStatus.streaming;
  bool get isError => this == MessageStatus.error;
}

/// Pure domain entity representing a single chat message.
class Message extends Equatable {
  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.errorMessage,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final MessageStatus status;
  final String? errorMessage;

  /// Creates a copy of this message with updated fields.
  Message copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? createdAt,
    MessageStatus? status,
    String? errorMessage,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [id, role, content, createdAt, status, errorMessage];
}
