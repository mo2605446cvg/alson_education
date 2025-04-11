import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/services/storage_service.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/user.dart'; // استيراد User
import 'package:alson_education/constants/app_strings.dart';

class UploadContentScreen extends StatefulWidget {
  const UploadContentScreen({super.key});

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _titleController = TextEditingController();

  Future<void> uploadExcelFile(FilePickerResult? result) async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (result == null || result.files.single.path == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a title and select a file')));
      return;
    }

    try {
      final file = result.files.single;
      final bytes = await File(file.path!).readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      // حفظ الملف في التخزين المحلي
      final filePath = await StorageService.saveFile(file.name, bytes);

      // قراءة ملف Excel
      var excel = Excel.decodeBytes(bytes);
      var sheet = excel.tables.entries.first.value;
      String department = excel.tables.keys.first;

      // استخراج البيانات من Excel (تخطي العنوان)
      List<Map<String, dynamic>> excelData = [];
      for (var row in sheet.rows.skip(1)) {
        if (row.length >= 2) {
          excelData.add({
            'code': row[0]?.value.toString(), // كود الطالب (سيكون كلمة المرور)
            'username': row[1]?.value.toString(), // الاسم (اسم المستخدم)
            'department': department,
          });
        }
      }

      // حفظ الملف كمحتوى
      final content = Content(
        id: DateTime.now().toString(),
        title: _titleController.text,
        filePath: filePath,
        fileType: file.name.split('.').last.toLowerCase(),
        uploadedBy: appState.currentUserCode!,
        uploadDate: DateTime.now().toString(),
      );
      await DatabaseService().insertContent(content);

      // حفظ بيانات Excel في قاعدة البيانات على الخادم
      for (var row in excelData) {
        await DatabaseService().insertUser(User(
          code: row['code'] ?? '',
          username: row['username'] ?? '',
          department: row['department'] ?? '',
          role: 'user', // افتراضي، يمكن تعديله
          password: row['code'] ?? '', // استخدام الكود ككلمة مرور
        ));
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Excel file and data uploaded successfully')));
      _titleController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('upload_content', appState.language)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('title', appState.language),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['xlsx', 'xls'],
                    );
                    uploadExcelFile(result);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(AppStrings.get('pick_file', appState.language)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
