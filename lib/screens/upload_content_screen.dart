import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/database/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class UploadContentScreen extends StatefulWidget {
  @override
  _UploadContentScreenState createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _filePath;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _filePath = result.files.single.path);
    }
  }

  Future<void> _uploadContent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يجب اختيار ملف أولاً')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final file = File(_filePath!);
      final fileName = _filePath!.split('/').last;
      final appDir = await getApplicationDocumentsDirectory();
      final savedFile = await file.copy('${appDir.path}/$fileName');

      final db = await DatabaseHelper.instance.database;
      await db.insert('content', {
        'title': _titleController.text,
        'file_path': savedFile.path,
        'file_type': fileName.split('.').last,
        'uploaded_by': 'admin123', // Replace with actual user code
        'upload_date': DateTime.now().toString(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفع المحتوى بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('رفع محتوى جديد')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان المحتوى',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'يجب إدخال العنوان' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.attach_file),
                label: Text('اختر ملف'),
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
              Text(_filePath ?? 'لم يتم اختيار ملف'),
              SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadContent,
                      child: Text('رفع المحتوى', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}