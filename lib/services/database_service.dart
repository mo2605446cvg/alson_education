import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/message.dart';

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        code TEXT PRIMARY KEY,
        username TEXT,
        department TEXT,
        division TEXT,
        role TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE contents(
        id TEXT PRIMARY KEY,
        title TEXT,
        file_path TEXT,
        poster_path TEXT,
        file_type TEXT,
        uploaded_by TEXT,
        upload_date TEXT,
        department TEXT,
        division TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE messages(
        id TEXT PRIMARY KEY,
        content TEXT,
        sender_id TEXT,
        department TEXT,
        division TEXT,
        timestamp TEXT
      )
    ''');

    // إضافة حسابي أدمن
    await db.insert('users', User(
      code: 'ADMIN001',
      username: 'Admin One',
      department: 'General',
      division: 'None',
      role: 'admin',
      password: 'ADMIN001',
    ).toMap());
    await db.insert('users', User(
      code: 'ADMIN002',
      username: 'Admin Two',
      department: 'General',
      division: 'None',
      role: 'admin',
      password: 'ADMIN002',
    ).toMap());
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN division TEXT');
      await db.execute('ALTER TABLE contents ADD COLUMN poster_path TEXT');
      await db.execute('ALTER TABLE contents ADD COLUMN department TEXT');
      await db.execute('ALTER TABLE contents ADD COLUMN division TEXT');
      await db.execute('''
        CREATE TABLE messages(
          id TEXT PRIMARY KEY,
          content TEXT,
          sender_id TEXT,
          department TEXT,
          division TEXT,
          timestamp TEXT
        )
      ''');
    }
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query('users', where: 'username = ?', whereArgs: [username]);
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((e) => User.fromMap(e)).toList();
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

  Future<List<Content>> getContents(String department, {String? division}) async {
    final db = await database;
    final result = await db.query(
      'contents',
      where: 'department = ? AND (division = ? OR division IS NULL)',
      whereArgs: [department, division ?? ''],
    );
    return result.map((e) => Content.fromMap(e)).toList();
  }

  Future<void> insertContent(Content content) async {
    final db = await database;
    await db.insert('contents', content.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> getTotalUsers() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return result.first['count'] as int;
  }

  Future<int> getActiveUsers() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users WHERE role != "inactive"');
    return result.first['count'] as int;
  }

  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert('messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Message>> getMessages(String department, String division) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where: 'department = ? AND division = ?',
      whereArgs: [department, division],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => Message.fromMap(e)).toList();
  }
}
