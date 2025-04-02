class User {
  final String code;
  final String username;
  final String department;
  final String role;
  final String password;

  User({
    required this.code,
    required this.username,
    required this.department,
    required this.role,
    required this.password,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      code: map['code'],
      username: map['username'],
      department: map['department'],
      role: map['role'],
      password: map['password'],
    );
  }
}