import 'package:flutter_test/flutter_test.dart';
import 'package:localmsg/models/peer.dart';
import 'package:localmsg/services/discovery_service.dart';

Peer _peer(String id, DateTime lastSeen) => Peer(
  id: id,
  alias: 'peer-$id',
  platform: 'linux',
  ip: '192.168.1.$id',
  port: 12345,
  lastSeen: lastSeen,
);

void main() {
  test('pruneStalePeers keeps recently-seen peers and drops stale ones', () {
    final now = DateTime(2026, 7, 23, 12, 0, 0);
    final peers = {
      'fresh': _peer('1', now.subtract(const Duration(seconds: 5))),
      'stale': _peer('2', now.subtract(const Duration(seconds: 15))),
      'boundary': _peer('3', now.subtract(const Duration(seconds: 10))),
    };

    final result = DiscoveryService.pruneStalePeers(peers, now);

    expect(result.containsKey('fresh'), isTrue);
    expect(result.containsKey('stale'), isFalse);
    expect(result.containsKey('boundary'), isTrue);
  });

  test('pruneStalePeers does not mutate the input map', () {
    final now = DateTime(2026, 7, 23, 12, 0, 0);
    final peers = {
      'stale': _peer('9', now.subtract(const Duration(seconds: 30))),
    };

    DiscoveryService.pruneStalePeers(peers, now);

    expect(peers.containsKey('stale'), isTrue);
  });
}
