class Peer {
  final String id;
  final String alias;
  final String platform;
  final String ip;
  final int port;
  final DateTime lastSeen;

  Peer({
    required this.id,
    required this.alias,
    required this.platform,
    required this.ip,
    required this.port,
    required this.lastSeen,
  });

  Peer copyWith({
    String? alias,
    String? platform,
    String? ip,
    int? port,
    DateTime? lastSeen,
  }) {
    return Peer(
      id: id,
      alias: alias ?? this.alias,
      platform: platform ?? this.platform,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Uri messageUri() =>
      Uri(scheme: 'http', host: ip, port: port, path: '/message');
}
