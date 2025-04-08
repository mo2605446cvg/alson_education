class Content {
  final String? id;
  final String title;
  final String filePath;
  final String fileType;
  final String uploadedBy;
  final String uploadDate;

  Content({
    this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    required this.uploadedBy,
    required this.uploadDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'file_type': fileType,
      'uploaded_by': uploadedBy,
      'upload_date': uploadDate,
    };
  }

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      id: map['id'] as String?,
      title: map['title'] as String,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      uploadedBy: map['uploaded_by'] as String,
      uploadDate: map['upload_date'] as String,
    );
  }
}
