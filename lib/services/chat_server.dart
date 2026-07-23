import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../models/chat_message.dart';
import 'chat_store.dart';

/// Tiny HTTP server that receives messages posted by other peers and
/// pushes them into [ChatStore]. Bound to an OS-assigned port (0) so
/// multiple instances can coexist on one machine during development.
class ChatServer {
  final ChatStore chatStore;

  ChatServer({required this.chatStore});

  HttpServer? _server;

  int get port => _server?.port ?? 0;

  Future<void> start() async {
    _server = await shelf_io.serve(_handler, InternetAddress.anyIPv4, 0);
  }

  Future<shelf.Response> _handler(shelf.Request request) async {
    if (request.method != 'POST' || request.url.path != 'message') {
      return shelf.Response.notFound('not found');
    }
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final message = ChatMessage.fromJson(json, isMine: false);
      chatStore.add(message.fromId, message);
      return shelf.Response.ok('ok');
    } catch (_) {
      return shelf.Response.badRequest(body: 'invalid payload');
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
  }
}
