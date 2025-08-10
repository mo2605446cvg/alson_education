import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ContentUpload extends StatefulWidget {
  const ContentUpload({super.key});

  @override
  _ContentUploadState createState() => _ContentUploadState();
}

class _ContentUploadState extends State<ContentUpload> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في اختيار الملف')),
      );
    }
  }

  Future<void> _uploadContent() async {
    if (_titleController.text.trim().isEmpty || _selectedFile == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال العنوان، النبذة، واختيار ملف')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      await uploadContent(
        _titleController.text,
        _selectedFile!,
        user.code,
        user.department,
        user.division,
        _descriptionController.text,
      );
      _titleController.clear();
      _descriptionController.clear();
      setState(() => _selectedFile = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع المحتوى بنجاح')),
      );
      Navigator.pushReplacementNamed(context, '/content');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في رفع المحتوى: تأكد من الاتصال بالإنترنت')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;
    if (user.role != 'admin') {
      return Scaffold(
        appBar: AppBarWidget(isAdmin: false),
        body: const Center(
          child: Text(
            'غير مصرح لك برفع المحتوى',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: textColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarWidget(isAdmin: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'رفع محتوى',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'عنوان المحتوى',
                        hintStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'نبذة عن المحتوى',
                        hintStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickFile,
                      child: const Text('اختيار ملف', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                    if (_selectedFile != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'الملف المختار: ${_selectedFile!.path.split('/').last}',
                        style: const TextStyle(color: textColor, fontFamily: 'Cairo'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _uploadContent,
                      child: Text(
                        _isLoading ? 'جارٍ الرفع...' : 'رفع المحتوى',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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