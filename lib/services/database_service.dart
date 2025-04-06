import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alson_education.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
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

    var adminExists = await db.rawQuery("SELECT * FROM users WHERE code='admin123'");
    if (adminExists.isEmpty) {
      await db.rawInsert(
          "INSERT INTO users (code, username, department, role, password) VALUES (?, ?, ?, ?, ?)",
          ['admin123', 'Admin', 'إدارة', 'admin', 'adminpass']);
    }
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((json) => User.fromMap(json)).toList();
  }

  Future<User?> getUser(String code) async {
    final db = await database;
    final result = await db.query('users', where: 'code = ?', whereArgs: [code]);
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update('users', user.toMap(), where: 'code = ?', whereArgs: [user.code]);
  }

  Future<void> deleteUser(String code) async {
    final db = await database;
    await db.delete('users', where: 'code = ?', whereArgs: [code]);
  }

  Future<List<Content>> getContents() async {
    final db = await database;
    final result = await db.query('content');
    return result.map((json) => Content.fromMap(json)).toList();
  }

  Future<void> insertContent(Content content) async {
    final db = await database;
    await db.insert('content', content.toMap());
  }

  Future<List<Map>> getChat(String senderCode, String receiverCode) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM chat WHERE (sender_code = ? AND receiver_code = ?) OR (sender_code = ? AND receiver_code = ?) ORDER BY timestamp
    ''', [senderCode, receiverCode, receiverCode, senderCode]);
  }

  Future<void> insertChat(String senderCode, String receiverCode, String message) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO chat (sender_code, receiver_code, message, timestamp) VALUES (?, ?, ?, ?)
    ''', [senderCode, receiverCode, message, DateTime.now().toIso8601String()]);
  }
}