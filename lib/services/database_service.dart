import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:alson_education/utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  final _secureStorage = const FlutterSecureStorage();
  final _key = encrypt.Key.fromUtf8('my32lengthsupersecretkey12345678'); // مفتاح 32 بايت
  final _iv = encrypt.IV.fromLength(16);

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);
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
    await db.execute('''
    CREATE TABLE points (
      user_code TEXT PRIMARY KEY,
      points INTEGER DEFAULT 0,
      FOREIGN KEY (user_code) REFERENCES users(code)
    )
    ''');

    final encryptedPassword = _encryptPassword(AppConstants.defaultAdminPassword);
    await db.execute(
      "INSERT OR IGNORE INTO users (code, username, department, role, password) VALUES (?, ?, ?, ?, ?)",
      [AppConstants.defaultAdminCode, AppConstants.defaultAdminUsername, AppConstants.defaultAdminDepartment, 'admin', encryptedPassword],
    );
  }

  String _encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    return encrypter.encrypt(password, iv: _iv).base64;
  }

  String _decryptPassword(String encryptedPassword) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    return encrypter.decrypt64(encryptedPassword, iv: _iv);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    if (values.containsKey('password')) {
      values['password'] = _encryptPassword(values['password']);
    }
    return await db.insert(table, values);
  }

  Future<int> update(String table, Map<String, dynamic> values, String where, List<dynamic> whereArgs) async {
    final db = await database;
    if (values.containsKey('password')) {
      values['password'] = _encryptPassword(values['password']);
    }
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> addPoints(String userCode, int points) async {
    final db = await database;
    await db.execute(
      "INSERT OR IGNORE INTO points (user_code, points) VALUES (?, 0)",
      [userCode],
    );
    await db.execute(
      "UPDATE points SET points = points + ? WHERE user_code = ?",
      [points, userCode],
    );
  }

  Future<int> getPoints(String userCode) async {
    final db = await database;
    final result = await db.query('points', where: 'user_code = ?', whereArgs: [userCode]);
    return result.isNotEmpty ? result.first['points'] as int : 0;
  }
}
