import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';

/// In-memory message history per peer id. Cleared when the app restarts.
class ChatStore extends ChangeNotifier {
  final Map<String, List<ChatMessage>> _messagesByPeerId = {};

  List<ChatMessage> messagesFor(String peerId) =>
      List.unmodifiable(_messagesByPeerId[peerId] ?? const []);

  void add(String peerId, ChatMessage message) {
    _messagesByPeerId.putIfAbsent(peerId, () => []).add(message);
    notifyListeners();
  }
}
