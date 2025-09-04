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
      code: json['code']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      division: json['division']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
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