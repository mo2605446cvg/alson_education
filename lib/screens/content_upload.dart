
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';

class ContentUpload extends StatefulWidget {
  const ContentUpload({super.key});

  @override
  _ContentUploadState createState() => _ContentUploadState();
}

class _ContentUploadState extends State<ContentUpload> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _filePath;
  String? _fileType;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'txt'],
      );
      if (result != null) {
        setState(() {
          _filePath = result.files.single.path;
          _fileType = result.files.single.extension;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في اختيار الملف: $e', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    }
  }

  Future<void> _uploadContent() async {
    if (_titleController.text.isEmpty || _filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال العنوان واختيار ملف', style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      final content = Content(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        fileType: _fileType ?? '',
        filePath: '',
        uploadedBy: user.code,
        uploadDate: DateTime.now().toIso8601String(),
      );
      await uploadContent(content, _filePath!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع المحتوى بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في رفع المحتوى: $e', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع محتوى', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  hintStyle: TextStyle(fontFamily: 'Cairo'),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'النبذة',
                  hintStyle: TextStyle(fontFamily: 'Cairo'),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('اختيار ملف', style: TextStyle(fontFamily: 'Cairo')),
              ),
              if (_filePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('الملف المختار: $_fileType', style: const TextStyle(fontFamily: 'Cairo')),
                ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadContent,
                      child: const Text('رفع', style: TextStyle(fontFamily: 'Cairo')),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}