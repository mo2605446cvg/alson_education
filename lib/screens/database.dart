import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'alson_education.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
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
        await db.insert('users', {
          'code': 'admin123',
          'username': 'Admin',
          'department': 'إدارة',
          'role': 'admin',
          'password': 'adminpass',
        });
      },
    );
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getUsersExceptCurrent(String currentCode) async {
    final db = await database;
    return await db.query('users', where: 'code != ?', whereArgs: [currentCode]);
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String senderCode, String receiverCode) async {
    final db = await database;
    return await db.query(
      'chat',
      where: '(sender_code = ? AND receiver_code = ?) OR (sender_code = ? AND receiver_code = ?)',
      whereArgs: [senderCode, receiverCode, receiverCode, senderCode],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> sendMessage(String senderCode, String receiverCode, String message) async {
    final db = await database;
    await db.insert('chat', {
      'sender_code': senderCode,
      'receiver_code': receiverCode,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> uploadContent(String title, String filePath, String fileType, String uploadedBy) async {
    final db = await database;
    await db.insert('content', {
      'title': title,
      'file_path': filePath,
      'file_type': fileType,
      'uploaded_by': uploadedBy,
      'upload_date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getContent() async {
    final db = await database;
    return await db.query('content');
  }
}