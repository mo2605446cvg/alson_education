class Message {
  final String id;
  final String content;
  final String senderId;
  final String department;
  final String division;
  final String timestamp;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.department,
    required this.division,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'sender_id': senderId,
      'department': department,
      'division': division,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      content: map['content'] as String,
      senderId: map['sender_id'] as String,
      department: map['department'] as String,
      division: map['division'] as String,
      timestamp: map['timestamp'] as String,
    );
  }
}
