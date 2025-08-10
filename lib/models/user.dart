
class User {
  final String id;
  final String code;
  final String name;
  final String role;

  User({
    required this.id,
    required this.code,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'role': role,
    };
  }
}
