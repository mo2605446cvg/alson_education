class AlsonEducationUser {
  final String code;
  final String username;
  final String department;
  final String role;
  final String password;

  AlsonEducationUser({
    required this.code,
    required this.username,
    required this.department,
    required this.role,
    required this.password,
  });

  factory AlsonEducationUser.fromMap(Map<String, dynamic> map) {
    return AlsonEducationUser(
      code: map['code'],
      username: map['username'],
      department: map['department'],
      role: map['role'],
      password: map['password'],
    );
  }
}