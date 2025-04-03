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

  // تحويل الكائن إلى Map لتخزينه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'username': username,
      'department': department,
      'role': role,
      'password': password,
    };
  }

  // إنشاء كائن User من Map (نتيجة الاستعلام من قاعدة البيانات)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      code: map['code'] as String,
      username: map['username'] as String,
      department: map['department'] as String,
      role: map['role'] as String,
      password: map['password'] as String,
    );
  }

  // تحويل إلى JSON (إذا احتجت إلى تخزين أو نقل البيانات)
  Map<String, dynamic> toJson() => toMap();

  // إنشاء من JSON
  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);

  @override
  String toString() {
    return 'User(code: $code, username: $username, department: $department, role: $role, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.code == code &&
        other.username == username &&
        other.department == department &&
        other.role == role &&
        other.password == password;
  }

  @override
  int get hashCode {
    return code.hashCode ^
        username.hashCode ^
        department.hashCode ^
        role.hashCode ^
        password.hashCode;
  }
}
