import 'package:hive/hive.dart';

part 'content.g.dart';

@HiveType(typeId: 1)
class Content {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final String fileType;

  @HiveField(4)
  final String uploadedBy;

  @HiveField(5)
  final String uploadDate;

  Content({
    this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    required this.uploadedBy,
    required this.uploadDate,
  });
}