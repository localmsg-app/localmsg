import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../models/peer.dart';

/// Sends a chat message to a peer over HTTP. Returns true on success.
class MessageClient {
  Future<bool> send(Peer peer, ChatMessage message) async {
    try {
      final response = await http
          .post(
            peer.messageUri(),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(message.toJson()),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
