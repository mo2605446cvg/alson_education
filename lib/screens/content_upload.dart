import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';
import 'dart:io';

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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'txt'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadContent() async {
    if (_titleController.text.trim().isEmpty || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال العنوان واختيار ملف')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع المحتوى بنجاح')),
      );
      Navigator.pop(context);
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

    return Scaffold(
      appBar: AppBarWidget(isAdmin: user.role == 'admin'),
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
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'عنوان المحتوى',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintStyle: const TextStyle(fontFamily: 'Cairo'),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'نبذة عن المحتوى',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintStyle: const TextStyle(fontFamily: 'Cairo'),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('اختيار ملف', style: TextStyle(fontFamily: 'Cairo')),
              ),
              if (_selectedFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'الملف المختار: ${_selectedFile!.path.split('/').last}',
                    style: const TextStyle(color: textColor, fontFamily: 'Cairo'),
                    textAlign: TextAlign.center,
                  ),
                ),
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