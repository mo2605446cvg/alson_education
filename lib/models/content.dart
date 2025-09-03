// ملف: content.dart
class Content {
  final String id;
  final String title;
  final String filePath;
  final String fileType;
  final String fileSize;
  final String uploadedBy;
  final String uploadDate;
  final String description;
  final String department;
  final String division;
  final String formattedSize;

  Content({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadDate,
    required this.description,
    required this.department,
    required this.division,
  }) : formattedSize = _formatSize(fileSize);

  static String _formatSize(String size) {
    try {
      double sizeNum = double.parse(size);
      List<String> units = ['B', 'KB', 'MB', 'GB'];
      int unitIndex = 0;
      
      while (sizeNum >= 1024 && unitIndex < units.length - 1) {
        sizeNum /= 1024;
        unitIndex++;
      }
      
      return '${sizeNum.toStringAsFixed(2)} ${units[unitIndex]}';
    } catch (e) {
      return '0 B';
    }
  }

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'] ?? '',
      fileSize: json['file_size']?.toString() ?? '0',
      uploadedBy: json['uploaded_by'] ?? '',
      uploadDate: json['upload_date'] ?? '',
      description: json['description'] ?? '',
      department: json['department'] ?? '',
      division: json['division'] ?? '',
    );
  }
}