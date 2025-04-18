class User {
  final String code;
  final String username;
  final String department;
  final String division;
  final String role;
  final String password;

  User({
    required this.code,
    required this.username,
    required this.department,
    required this.division,
    required this.role,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'username': username,
      'department': department,
      'division': division,
      'role': role,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      code: map['code'] as String,
      username: map['username'] as String,
      department: map['department'] as String,
      division: map['division'] as String? ?? '',
      role: map['role'] as String,
      password: map['password'] as String,
    );
  }
}
