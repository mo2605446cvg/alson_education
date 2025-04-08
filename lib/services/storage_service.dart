import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> getUploadsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final uploadsDir = Directory('${directory.path}/uploads');
    if (!await uploadsDir.exists()) {
      await uploadsDir.create(recursive: true);
    }
    return uploadsDir.path;
  }

  static Future<String> saveFile(String fileName, List<int> bytes) async {
    final uploadsDir = await getUploadsDirectory();
    final filePath = '$uploadsDir/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }
}