import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:alson_education/utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

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

    await db.execute(
        "INSERT OR IGNORE INTO users (code, username, department, role, password) VALUES (?, ?, ?, ?, ?)",
        [AppConstants.defaultAdminCode, AppConstants.defaultAdminUsername, AppConstants.defaultAdminDepartment, 'admin', AppConstants.defaultAdminPassword]);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy, // تأكد إن orderBy موجود هنا
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<int> update(String table, Map<String, dynamic> values, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}
