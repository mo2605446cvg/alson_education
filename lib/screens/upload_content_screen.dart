import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/services/storage_service.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/constants/colors.dart';

class UploadContentScreen extends StatefulWidget {
  @override
  _UploadContentScreenState createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _titleController = TextEditingController();

  Future<void> uploadContent(FilePickerResult? result) async {
    if (result != null && result.files.single.path != null && _titleController.text.isNotEmpty) {
      final appState = Provider.of<AppState>(context, listen: false);
      final file = result.files.single;
      final bytes = await File(file.path!).readAsBytes();
      final filePath = await StorageService.saveFile(file.name, bytes);
      final fileType = file.name.split('.').last.toLowerCase();

      final content = Content(
        title: _titleController.text,
        filePath: filePath,
        fileType: fileType,
        uploadedBy: appState.currentUserCode!,
        uploadDate: DateTime.now().toIso8601String(),
      );

      final db = await DatabaseService.instance.database;
      await db.insert('content', content.toMap());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم رفع المحتوى بنجاح')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال عنوان واختيار ملف')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('رفع المحتوى')),
      body: Container(
        padding: EdgeInsets.all(20),
        color: SECONDARY_COLOR,
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'عنوان المحتوى', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                uploadContent(result);
              },
              child: Text('اختر ملف'),
              style: ElevatedButton.styleFrom(primary: PRIMARY_COLOR, onPrimary: Colors.white),
            ),
            Text('الصيغ المدعومة: PDF, صور (PNG, JPG), نصوص (TXT)', style: TextStyle(color: Colors.grey)),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(primary: ACCENT_COLOR, onPrimary: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}