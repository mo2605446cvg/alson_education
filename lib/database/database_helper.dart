import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

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

    // Add admin user if not exists
    var admin = await db.query('users', where: 'code = ?', whereArgs: ['admin123']);
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

  // Add other CRUD operations...
}