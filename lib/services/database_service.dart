import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/lesson.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alson_education.db');
    await _ensureAdminUser();
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        code TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        department TEXT NOT NULL,
        role TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS content (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        uploaded_by TEXT NOT NULL,
        upload_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lessons (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        level TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // جدول جديد لتخزين بيانات Excel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS excel_users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        department TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS excel_users (
          id TEXT PRIMARY KEY,
          username TEXT NOT NULL,
          password TEXT NOT NULL,
          department TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _ensureAdminUser() async {
    final db = await database;
    try {
      final adminExists = await db.query(
        'users',
        where: 'code = ?',
        whereArgs: ['admin123'],
      );
      if (adminExists.isEmpty) {
        await db.insert(
          'users',
          User(
            code: 'admin123',
            username: 'Admin',
            department: 'إدارة',
            role: 'admin',
            password: 'adminpass',
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        print('Admin user created');
      } else {
        print('Admin user already exists');
      }
    } catch (e) {
      print('Error ensuring admin user: $e');
    }
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Content>> getContents() async {
    final db = await database;
    final result = await db.query('content');
    return result.map((map) => Content.fromMap(map)).toList();
  }

  Future<void> insertContent(Content content) async {
    final db = await database;
    await db.insert(
      'content',
      content.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Lesson>> getLessons() async {
    final db = await database;
    final result = await db.query('lessons');
    return result.map((map) => Lesson.fromMap(map)).toList();
  }

  Future<void> insertLesson(Lesson lesson) async {
    final db = await database;
    await db.insert(
      'lessons',
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> toggleFavoriteLesson(String id) async {
    final db = await database;
    final lessonResult = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (lessonResult.isNotEmpty) {
      final lesson = Lesson.fromMap(lessonResult.first);
      await db.update(
        'lessons',
        {'is_favorite': lesson.isFavorite ? 0 : 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<Lesson>> searchLessons(String query) async {
    final db = await database;
    final result = await db.query(
      'lessons',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((map) => Lesson.fromMap(map)).toList();
  }

  // دالة جديدة لحفظ بيانات Excel
  Future<void> insertExcelUsers(List<Map<String, dynamic>> data) async {
    final db = await database;
    for (var row in data) {
      await db.insert(
        'excel_users',
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString() + row['code']!, // إنشاء ID فريد
          'username': row['username'],
          'password': row['password'],
          'department': row['department'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
