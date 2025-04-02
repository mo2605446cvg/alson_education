import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:alson_education/models/alson_education_user.dart';

class AlsonEducationDatabase {
  static final AlsonEducationDatabase instance = AlsonEducationDatabase._init();
  static Database? _database;

  AlsonEducationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alson_education.db');
    return _database!;
  }

  static Future<void> initDB() async {
    await instance.database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        code TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        department TEXT NOT NULL,
        role TEXT DEFAULT 'user',
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE content (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        uploaded_by TEXT NOT NULL,
        upload_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_code TEXT NOT NULL,
        receiver_code TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // إضافة مستخدم أدمن افتراضي إذا لم يكن موجوداً
    final admin = await db.query('users', where: 'code = ?', whereArgs: ['admin123']);
    if (admin.isEmpty) {
      await db.insert('users', {
        'code': 'admin123',
        'username': 'Admin',
        'department': 'Management',
        'role': 'admin',
        'password': 'adminpass'
      });
    }
  }

  static Future<List<AlsonEducationUser>> getAllUsers() async {
    final db = await instance.database;
    final users = await db.query('users');
    return users.map((user) => AlsonEducationUser.fromMap(user)).toList();
  }

  static Future<int> createUser(AlsonEducationUser user) async {
    final db = await instance.database;
    return await db.insert('users', {
      'code': user.code,
      'username': user.username,
      'department': user.department,
      'role': user.role,
      'password': user.password,
    });
  }
}
