import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/peer.dart';
import 'device_identity_service.dart';

/// Discovers other localmsg instances on the same LAN via UDP multicast,
/// and keeps a live list of peers seen recently.
class DiscoveryService extends ChangeNotifier {
  static const String multicastGroup = '239.100.100.100';
  static const int discoveryPort = 53320;
  static const Duration announceInterval = Duration(seconds: 3);
  static const Duration staleAfter = Duration(seconds: 10);
  static const Duration cleanupInterval = Duration(seconds: 2);

  final DeviceIdentityService identity;

  /// Returns the current port of the local chat HTTP server. Passed as a
  /// callback because that port is only known once the server has bound
  /// (it uses port 0 / OS-assigned) and discovery may start slightly before.
  final int Function() servicePort;

  DiscoveryService({required this.identity, required this.servicePort});

  RawDatagramSocket? _socket;
  Timer? _announceTimer;
  Timer? _cleanupTimer;

  final Map<String, Peer> _peers = {};
  List<Peer> get peers => _peers.values.toList(growable: false);

  Future<void> start() async {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      discoveryPort,
      reuseAddress: true,
    );
    socket.joinMulticast(InternetAddress(multicastGroup));
    socket.listen(_onEvent);
    _socket = socket;

    _announceTimer = Timer.periodic(announceInterval, (_) => _announce());
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _pruneStale());
    _announce();
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _socket?.receive();
    if (datagram == null) return;

    try {
      final json =
          jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>;
      if (json['type'] != 'announce') return;

      final peerId = json['id'] as String;
      // Multicast loopback can echo our own packets back to us.
      if (peerId == identity.id) return;

      _peers[peerId] = Peer(
        id: peerId,
        alias: json['alias'] as String,
        platform: json['platform'] as String,
        ip: datagram.address.address,
        port: json['port'] as int,
        lastSeen: DateTime.now(),
      );
      notifyListeners();
    } catch (_) {
      // Ignore malformed/unrelated packets on the multicast group.
    }
  }

  void _announce() {
    final socket = _socket;
    if (socket == null || !identity.ready) return;

    final payload = jsonEncode({
      'type': 'announce',
      'id': identity.id,
      'alias': identity.alias,
      'platform': identity.platform,
      'port': servicePort(),
    });
    socket.send(
      utf8.encode(payload),
      InternetAddress(multicastGroup),
      discoveryPort,
    );
  }

  void _pruneStale() {
    final before = _peers.length;
    final pruned = pruneStalePeers(_peers, DateTime.now());
    if (pruned.length != before) {
      _peers
        ..clear()
        ..addAll(pruned);
      notifyListeners();
    }
  }

  /// Pure helper (no socket involved) so peer-expiry logic can be unit tested.
  @visibleForTesting
  static Map<String, Peer> pruneStalePeers(
    Map<String, Peer> peers,
    DateTime now,
  ) {
    final result = Map<String, Peer>.from(peers);
    result.removeWhere((_, peer) => now.difference(peer.lastSeen) > staleAfter);
    return result;
  }

  @override
  void dispose() {
    _announceTimer?.cancel();
    _cleanupTimer?.cancel();
    _socket?.close();
    super.dispose();
  }
}
