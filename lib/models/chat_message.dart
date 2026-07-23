class ChatMessage {
  final String fromId;
  final String fromAlias;
  final String text;
  final DateTime timestamp;
  final bool isMine;

  ChatMessage({
    required this.fromId,
    required this.fromAlias,
    required this.text,
    required this.timestamp,
    required this.isMine,
  });

  Map<String, dynamic> toJson() => {
    'fromId': fromId,
    'fromAlias': fromAlias,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  static ChatMessage fromJson(
    Map<String, dynamic> json, {
    required bool isMine,
  }) {
    return ChatMessage(
      fromId: json['fromId'] as String,
      fromAlias: json['fromAlias'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isMine: isMine,
    );
  }
}
