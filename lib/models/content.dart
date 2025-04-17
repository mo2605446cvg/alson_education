class Content {
  final String? id;
  final String title;
  final String filePath;
  final String? posterPath;
  final String fileType;
  final String uploadedBy;
  final String uploadDate;
  final String department;
  final String division;

  Content({
    this.id,
    required this.title,
    required this.filePath,
    this.posterPath,
    required this.fileType,
    required this.uploadedBy,
    required this.uploadDate,
    required this.department,
    required this.division,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'poster_path': posterPath,
      'file_type': fileType,
      'uploaded_by': uploadedBy,
      'upload_date': uploadDate,
      'department': department,
      'division': division,
    };
  }

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      id: map['id'] as String?,
      title: map['title'] as String? ?? '',
      filePath: map['file_path'] as String? ?? '',
      posterPath: map['poster_path'] as String?,
      fileType: map['file_type'] as String? ?? '',
      uploadedBy: map['uploaded_by'] as String? ?? '',
      uploadDate: map['upload_date'] as String? ?? '',
      department: map['department'] as String? ?? '',
      division: map['division'] as String? ?? '',
    );
  }
}
