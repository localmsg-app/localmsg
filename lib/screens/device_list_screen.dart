import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/device_identity_service.dart';
import '../services/discovery_service.dart';
import '../widgets/peer_tile.dart';
import 'chat_screen.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

  Future<void> _editAlias(
    BuildContext context,
    DeviceIdentityService identity,
  ) async {
    final controller = TextEditingController(text: identity.alias);
    final newAlias = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nom de cet appareil'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (newAlias != null && newAlias.trim().isNotEmpty) {
      await identity.updateAlias(newAlias);
    }
  }

  @override
  Widget build(BuildContext context) {
    final identity = context.watch<DeviceIdentityService>();
    final discovery = context.watch<DiscoveryService>();
    final peers = discovery.peers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalMsg'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Renommer cet appareil',
            onPressed: () => _editAlias(context, identity),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Vous êtes : ${identity.alias}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: peers.isEmpty
                ? const Center(
                    child: Text('Recherche d\'appareils sur le réseau...'),
                  )
                : ListView.builder(
                    itemCount: peers.length,
                    itemBuilder: (context, index) {
                      final peer = peers[index];
                      return PeerTile(
                        peer: peer,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(peer: peer),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
