import 'package:flutter/material.dart';

import '../models/peer.dart';

class PeerTile extends StatelessWidget {
  final Peer peer;
  final VoidCallback onTap;

  const PeerTile({super.key, required this.peer, required this.onTap});

  IconData get _platformIcon {
    switch (peer.platform) {
      case 'android':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      case 'macos':
        return Icons.laptop_mac;
      case 'windows':
        return Icons.laptop_windows;
      case 'linux':
        return Icons.laptop;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Icon(_platformIcon)),
      title: Text(peer.alias),
      subtitle: Text(peer.ip),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
