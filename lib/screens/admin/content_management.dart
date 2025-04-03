import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  final _titleController = TextEditingController();

  Future<void> _uploadContent() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && _titleController.text.isNotEmpty) {
      final file = result.files.first;
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/${file.name}';
      await File(file.path!).copy(filePath);

      final db = DatabaseService.instance;
      await db.insert('content', {
        'title': _titleController.text,
        'file_path': filePath,
        'file_type': file.extension,
        'uploaded_by': 'admin123', // يمكن استبدالها بالمستخدم الحالي
        'upload_date': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم رفع المحتوى بنجاح', style: TextStyle(color: Colors.green))));
      _titleController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال عنوان المحتوى واختيار ملف', style: TextStyle(color: Colors.red))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('رفع المحتوى', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'عنوان المحتوى', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadContent,
              child: Text('اختر ملف'),
              style: ElevatedButton.styleFrom(primary: AppColors.primaryColor, minimumSize: Size(200, 50)),
            ),
            Text('الصيغ المدعومة: PDF, صور (PNG, JPG), نصوص (TXT)', style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(primary: AppColors.accentColor, minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
