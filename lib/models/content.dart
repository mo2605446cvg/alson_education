
class Content {
  final String id;
  final String title;
  final String description;
  final String fileType;
  final String filePath;
  final String uploadedBy;
  final String uploadDate;

  Content({
    required this.id,
    required this.title,
    required this.description,
    required this.fileType,
    required this.filePath,
    required this.uploadedBy,
    required this.uploadDate,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileType: json['file_type'] ?? '',
      filePath: json['file_path'] ?? '',
      uploadedBy: json['uploaded_by'] ?? '',
      uploadDate: json['upload_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'file_type': fileType,
      'file_path': filePath,
      'uploaded_by': uploadedBy,
      'upload_date': uploadDate,
    };
  }
}
