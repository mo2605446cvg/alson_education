import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class AlsonEducationDatabase {
  static final AlsonEducationDatabase instance = AlsonEducationDatabase._init();
  static Database? _database;

  AlsonEducationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alson_education.db');
    return _database!;
  }

  static Future initDB() async {
    await instance.database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        code TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        department TEXT NOT NULL,
        role TEXT DEFAULT 'user',
        password TEXT NOT NULL
      )
    ''');

    // بقية الجداول بنفس النمط...
  }

  // جميع الدوال الأخرى بنفس النمط مع تعديل الاسم
  static Future<int> createUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', {
      'code': Uuid().v4().substring(0, 8),
      'username': user['username'],
      'department': user['department'],
      'password': user['password'],
      'role': user['role'] ?? 'user'
    });
  }
}