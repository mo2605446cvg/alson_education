class User {
  final String code;
  final String username;
  final String department;
  final String division;
  final String role;

  User({
    required this.code,
    required this.username,
    required this.department,
    required this.division,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      code: json['code'] ?? '',
      username: json['username'] ?? '',
      department: json['department'] ?? '',
      division: json['division'] ?? '',
      role: json['role'] ?? 'guest', // جعل الضيف هو القيمة الافتراضية
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'username': username,
      'department': department,
      'division': division,
      'role': role,
    };
  }
}