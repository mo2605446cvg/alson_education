import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/components/app_bar.dart';
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
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = result.files.first);
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
      );
      _titleController.clear();
      setState(() => _selectedFile = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع المحتوى بنجاح')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في رفع المحتوى')),
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
      body: Padding(
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
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'عنوان المحتوى',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _pickFile,
                    child: const Text('اختيار ملف', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                  ),
                  if (_selectedFile != null) ...[
                    const SizedBox(height: 8),
                    Text('الملف المختار: ${_selectedFile!.name}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _uploadContent,
                    child: Text(
                      _isLoading ? 'جارٍ الرفع...' : 'رفع المحتوى',
                      style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
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
    super.dispose();
  }
}