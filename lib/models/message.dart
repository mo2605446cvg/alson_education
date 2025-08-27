// ملف: message.dart
class Message {
  final String id;
  final String content;
  final String senderId;
  final String username;
  final String department;
  final String division;
  final String timestamp;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.username,
    required this.department,
    required this.division,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      senderId: json['sender_id'] ?? '',
      username: json['username'] ?? '',
      department: json['department'] ?? '',
      division: json['division'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}