// ملف: user.dart
class AppUser {
  final String code;
  final String username;
  final String department;
  final String division;
  final String role;

  AppUser({
    required this.code,
    required this.username,
    required this.department,
    required this.division,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      code: json['code'] ?? '',
      username: json['username'] ?? '',
      department: json['department'] ?? '',
      division: json['division'] ?? '',
      role: json['role'] ?? 'guest',
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
