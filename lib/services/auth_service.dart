import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/models/user.dart';

class AuthService {
  final DatabaseService _db = DatabaseService.instance;

  Future<User?> login(String username, String password) async {
    final users = await _db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (users.isNotEmpty) {
      return User.fromMap(users.first);
    }
    return null;
  }

  Future<void> logout() async {
    // يمكن إضافة منطق لتسجيل الخروج هنا، مثل مسح البيانات المخزنة
  }
}
