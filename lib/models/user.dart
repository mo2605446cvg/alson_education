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
      code: json['code'] as String,
      username: json['username'] as String,
      department: json['department'] as String,
      division: json['division'] as String,
      role: json['role'] as String,
    );
  }
}
