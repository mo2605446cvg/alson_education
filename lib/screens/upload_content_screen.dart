import 'package:flutter/material.dart';
import 'package:alson_education/screens/database.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UploadContentScreen extends StatefulWidget {
  const UploadContentScreen({super.key});

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _titleController = TextEditingController();

  Future<void> _uploadContent(String userCode) async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عنوان المحتوى', style: TextStyle(color: Colors.red))),
      );
      return;
    }
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/uploads/${result.files.single.name}';
      await Directory('${directory.path}/uploads').create(recursive: true);
      await file.copy(newPath);

      final db = DatabaseService();
      await db.uploadContent(
        _titleController.text,
        newPath,
        result.files.single.extension!.toLowerCase(),
        userCode,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع المحتوى بنجاح', style: TextStyle(color: Colors.green))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع المحتوى', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان المحتوى',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _uploadContent(user['code']),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
              child: const Text('اختر ملف'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600], foregroundColor: Colors.white),
              child: const Text('عودة'),
            ),
          ],
        ),
      ),
    );
  }
}