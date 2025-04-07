class Lesson {
  final String id;
  final String title;
  final String content;
  final String category;
  final String level;
  final bool isFavorite;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.level,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'level': level,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
      level: map['level'] as String,
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }
}
