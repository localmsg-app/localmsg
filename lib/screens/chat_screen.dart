import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../models/peer.dart';
import '../services/chat_store.dart';
import '../services/device_identity_service.dart';
import '../services/discovery_service.dart';
import '../services/message_client.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final Peer peer;

  const ChatScreen({super.key, required this.peer});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messageClient = MessageClient();
  bool _sending = false;
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(Peer peer) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final identity = context.read<DeviceIdentityService>();
    final chatStore = context.read<ChatStore>();

    final message = ChatMessage(
      fromId: identity.id,
      fromAlias: identity.alias,
      text: text,
      timestamp: DateTime.now(),
      isMine: true,
    );

    setState(() => _sending = true);
    _controller.clear();
    chatStore.add(peer.id, message);

    final ok = await _messageClient.send(peer, message);
    if (mounted) {
      setState(() => _sending = false);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message non envoyé : appareil injoignable'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryService>();

    Peer peer = widget.peer;
    var isOnline = false;
    for (final p in discovery.peers) {
      if (p.id == widget.peer.id) {
        peer = p;
        isOnline = true;
        break;
      }
    }

    final messages = context.watch<ChatStore>().messagesFor(peer.id);
    if (messages.length != _lastMessageCount) {
      _lastMessageCount = messages.length;
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(peer.alias),
            Text(
              isOnline ? 'En ligne' : 'Hors ligne',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('Aucun message pour le moment'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        MessageBubble(message: messages[index]),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _send(peer),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: _sending ? null : () => _send(peer),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
