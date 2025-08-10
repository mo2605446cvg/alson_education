class Content {
  final String id;
  final String title;
  final String filePath;
  final String fileType;
  final String uploadedBy;
  final String uploadDate;
  final String description;

  Content({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    required this.uploadedBy,
    required this.uploadDate,
    required this.description,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['file_path'] as String,
      fileType: json['file_type'] as String,
      uploadedBy: json['uploaded_by'] as String,
      uploadDate: json['upload_date'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}