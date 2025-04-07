import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String department;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String password;

  User({
    required this.code,
    required this.username,
    required this.department,
    required this.role,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'username': username,
      'department': department,
      'role': role,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      code: map['code'] as String,
      username: map['username'] as String,
      department: map['department'] as String,
      role: map['role'] as String,
      password: map['password'] as String,
    );
  }
}