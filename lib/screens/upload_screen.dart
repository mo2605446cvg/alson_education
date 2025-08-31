import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart' as app_user;

class UploadScreen extends StatefulWidget {
  final ApiService apiService;
  final app_user.AppUser user;

  UploadScreen({required this.apiService, required this.user});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedFile;
  String _fileName = 'لم يتم اختيار ملف';
  bool _isUploading = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'txt'],
        type: FileType.custom,
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = 'الملف المختار: ${result.files.single.name}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في اختيار الملف')),
      );
    }
  }

  Future<void> _uploadContent() async {
    if (_titleController.text.isEmpty ||
        _selectedFile == null ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال العنوان، النبذة، واختيار ملف')),
      );
      return;
    }

    // التحقق من الاتصال أولاً
    if (!await widget.apiService.checkConnection()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الاتصال بالسيرفر')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final success = await widget.apiService.uploadContent(
        title: _titleController.text,
        file: _selectedFile!,
        uploadedBy: widget.user.code,
        department: widget.user.department,
        division: widget.user.division,
        description: _descriptionController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفع المحتوى بنجاح')),
        );
        
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedFile = null;
          _fileName = 'لم يتم اختيار ملف';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في رفع المحتوى: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('رفع محتوى جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('رفع محتوى', style: Theme.of(context).textTheme.displayMedium),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'عنوان المحتوى',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'نبذة عن المحتوى',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 5,
                    minLines: 3,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text('اختيار ملف'),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15)),
                  ),
                  SizedBox(height: 16),
                  Text(_fileName, textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadContent,
                    child: _isUploading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('رفع المحتوى'),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15)),
                  ),
                ],
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
    _descriptionController.dispose();
    super.dispose();
  }
}
