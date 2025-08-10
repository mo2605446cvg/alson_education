
class Message {
  final String id;
  final String userCode;
  final String messageText;
  final String timestamp;

  Message({
    required this.id,
    required this.userCode,
    required this.messageText,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      userCode: json['user_code'] ?? '',
      messageText: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_code': userCode,
      'message': messageText,
      'timestamp': timestamp,
    };
  }
}
