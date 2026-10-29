import 'package:flutter_test/flutter_test.dart';
import 'package:d_ai/features/chat/domain/entities/message.dart';

void main() {
  group('Message Entity', () {
    final now = DateTime(2026, 10, 28, 12, 0, 0);

    test('supports value equality via Equatable', () {
      final msg1 = Message(
        id: 'msg-1',
        role: MessageRole.user,
        content: 'Hello D',
        createdAt: now,
      );

      final msg2 = Message(
        id: 'msg-1',
        role: MessageRole.user,
        content: 'Hello D',
        createdAt: now,
      );

      expect(msg1, equals(msg2));
    });

    test('copyWith updates properties correctly', () {
      final original = Message(
        id: 'msg-1',
        role: MessageRole.assistant,
        content: 'Thinking...',
        createdAt: now,
        status: MessageStatus.streaming,
      );

      final updated = original.copyWith(
        content: 'Completed answer',
        status: MessageStatus.sent,
      );

      expect(updated.id, equals('msg-1'));
      expect(updated.content, equals('Completed answer'));
      expect(updated.status, equals(MessageStatus.sent));
      expect(updated.role, equals(MessageRole.assistant));
    });

    test('role helper getters work properly', () {
      final userMsg = Message(
        id: '1',
        role: MessageRole.user,
        content: 'hi',
        createdAt: now,
      );
      final assistantMsg = Message(
        id: '2',
        role: MessageRole.assistant,
        content: 'hi',
        createdAt: now,
      );

      expect(userMsg.role.isUser, isTrue);
      expect(userMsg.role.isAssistant, isFalse);
      expect(assistantMsg.role.isAssistant, isTrue);
    });
  });
}
