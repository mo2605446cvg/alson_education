import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:alson_education/widgets/custom_appbar.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  final _titleController = TextEditingController();
  bool _isUploading = false;

  Future<void> _uploadContent() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال عنوان المحتوى', style: TextStyle(color: AppColors.errorColor))),
      );
      return;
    }

    setState(() => _isUploading = true);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'txt'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/${file.name}';
      try {
        await File(file.path!).copy(filePath);
        final db = DatabaseService.instance;
        await db.insert('content', {
          'title': _titleController.text,
          'file_path': filePath,
          'file_type': file.extension ?? 'unknown',
          'uploaded_by': 'admin123', // يمكن استبدالها بكود المستخدم الحالي
          'upload_date': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفع المحتوى بنجاح', style: TextStyle(color: Colors.green))),
        );
        _titleController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في رفع الملف: $e', style: TextStyle(color: AppColors.errorColor))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لم يتم اختيار ملف', style: TextStyle(color: AppColors.errorColor))),
      );
    }
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'رفع المحتوى'),
      backgroundColor: AppColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان المحتوى',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            _isUploading
                ? CircularProgressIndicator(color: AppColors.primaryColor)
                : ElevatedButton(
                    onPressed: _uploadContent,
                    child: Text('اختر ملف', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: Size(200, 50),
                    ),
                  ),
            SizedBox(height: 10),
            Text('الصيغ المدعومة: PDF, صور (PNG, JPG), نصوص (TXT)', style: TextStyle(fontSize: 14, color: AppColors.textColor)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: Text('عودة', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                minimumSize: Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
