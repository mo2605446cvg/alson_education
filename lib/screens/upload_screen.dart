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
  String? _selectedDepartment;
  String? _selectedDivision;

  // قوائم الاختيار
  final List<String> _departments = ['قسم اللغة العربية', 'قسم اللغة الإنجليزية', 'قسم الترجمة', 'قسم العلوم الإنسانية'];
  final List<String> _divisions = ['الشعبة أ', 'الشعبة ب', 'الشعبة ج', 'الشعبة د'];

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'txt', 'doc', 'docx', 'mp4', 'mp3'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = 'الملف المختار: ${result.files.single.name}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في اختيار الملف: $e')),
      );
    }
  }

  Future<void> _uploadContent() async {
    if (_titleController.text.isEmpty ||
        _selectedFile == null ||
        _descriptionController.text.isEmpty ||
        _selectedDepartment == null ||
        _selectedDivision == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال جميع الحقول واختيار ملف')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final success = await widget.apiService.uploadContent(
        title: _titleController.text,
        file: _selectedFile!,
        uploadedBy: widget.user.username,
        department: _selectedDepartment!,
        division: _selectedDivision!,
        description: _descriptionController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفع المحتوى بنجاح')),
        );
        
        // مسح الحقول
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedFile = null;
          _fileName = 'لم يتم اختيار ملف';
          _selectedDepartment = null;
          _selectedDivision = null;
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
      body: SingleChildScrollView(
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
                  // حقل العنوان
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'عنوان المحتوى *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  SizedBox(height: 16),

                  // اختيار القسم
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: InputDecoration(
                      labelText: 'القسم *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _departments.map((String department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDepartment = newValue;
                      });
                    },
                  ),
                    SizedBox(height: 16),

                  // اختيار الشعبة
                  DropdownButtonFormField<String>(
                    value: _selectedDivision,
                    decoration: InputDecoration(
                      labelText: 'الشعبة *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.group),
                    ),
                    items: _divisions.map((String division) {
                      return DropdownMenuItem<String>(
                        value: division,
                        child: Text(division),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDivision = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // حقل الوصف
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'وصف المحتوى *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  // زر اختيار الملف
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file),
                        SizedBox(width: 8),
                        Text('اختيار ملف'),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 16),

                  // اسم الملف المختار
                  Text(
                    _fileName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedFile != null ? Colors.green : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),

                  // زر الرفع
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadContent,
                    child: _isUploading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_upload),
                              SizedBox(width: 8),
                              Text('رفع المحتوى'),
                            ],
                          ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
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
