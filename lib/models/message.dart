class Message {
  final String id;
  final String content;
  final String senderId;
  final String username;
  final String timestamp;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.username,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      senderId: json['sender_id'] as String,
      username: json['username'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}