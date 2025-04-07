import 'package:hive/hive.dart';

part 'lesson.g.dart';

@HiveType(typeId: 2)
class Lesson {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String level;

  @HiveField(5)
  bool isFavorite;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.level,
    this.isFavorite = false,
  });
}