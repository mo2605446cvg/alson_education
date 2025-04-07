import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/lesson.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Box<User>? _userBox;
  static Box<Content>? _contentBox;
  static Box<Lesson>? _lessonBox;

  DatabaseService._init();

  Future<void> initHive() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ContentAdapter());
    Hive.registerAdapter(LessonAdapter());

    _userBox = await Hive.openBox<User>('users');
    _contentBox = await Hive.openBox<Content>('content');
    _lessonBox = await Hive.openBox<Lesson>('lessons');

    if (!_userBox!.containsKey('admin123')) {
      _userBox!.put('admin123', User(code: 'admin123', username: 'Admin', department: 'إدارة', role: 'admin', password: 'adminpass'));
    }
  }

  Future<List<User>> getUsers() async => _userBox!.values.toList();

  Future<User?> getUser(String code) async => _userBox!.get(code);

  Future<void> insertUser(User user) async => _userBox!.put(user.code, user);

  Future<void> updateUser(User user) async => _userBox!.put(user.code, user);

  Future<void> deleteUser(String code) async => _userBox!.delete(code);

  Future<List<Content>> getContents() async => _contentBox!.values.toList();

  Future<void> insertContent(Content content) async => _contentBox!.put(content.id ?? DateTime.now().toString(), content);

  Future<List<Lesson>> getLessons() async => _lessonBox!.values.toList();

  Future<void> insertLesson(Lesson lesson) async => _lessonBox!.put(lesson.id, lesson);

  Future<void> toggleFavoriteLesson(String id) async {
    final lesson = _lessonBox!.get(id);
    if (lesson != null) {
      lesson.isFavorite = !lesson.isFavorite;
      await _lessonBox!.put(id, lesson);
    }
  }

  Future<List<Lesson>> searchLessons(String query) async {
    return _lessonBox!.values.where((lesson) => lesson.title.contains(query) || lesson.content.contains(query)).toList();
  }
}