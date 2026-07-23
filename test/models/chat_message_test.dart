import 'package:flutter_test/flutter_test.dart';
import 'package:localmsg/models/chat_message.dart';

void main() {
  test('toJson/fromJson round-trip preserves message content', () {
    final original = ChatMessage(
      fromId: 'device-123',
      fromAlias: 'Alice',
      text: 'Salut !',
      timestamp: DateTime.utc(2026, 7, 23, 10, 30),
      isMine: true,
    );

    final decoded = ChatMessage.fromJson(original.toJson(), isMine: false);

    expect(decoded.fromId, original.fromId);
    expect(decoded.fromAlias, original.fromAlias);
    expect(decoded.text, original.text);
    expect(decoded.timestamp, original.timestamp);
    expect(
      decoded.isMine,
      false,
    ); // isMine is set by the receiver, not carried over the wire
  });
}
