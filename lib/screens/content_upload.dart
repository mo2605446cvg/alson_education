
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
  PlatformFile? _file;
  String _department = 'Math';
  String _division = 'Division A';
  bool _isLoading = false;

  final List<String> departments = ['Math', 'Science', 'Computer', 'Physics', 'Chemistry'];
  final List<String> divisions = ['Division A', 'Division B'];

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );
      if (result != null) {
        setState(() => _file = result.files.first);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في اختيار الملف')),
      );
    }
  }

  Future<void> _handleUpload() async {
    if (_titleController.text.trim().isEmpty || _file == null) {
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
        _file!,
        user.code,
        _department,
        _division,
      );
      _titleController.clear();
      setState(() => _file = null);
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
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'رفع المحتوى',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 384),
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
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _department,
                      items: departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                      onChanged: user.role == 'admin' ? (value) => setState(() => _department = value!) : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _division,
                      items: divisions.map((div) => DropdownMenuItem(value: div, child: Text(div, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                      onChanged: user.role == 'admin' ? (value) => setState(() => _division = value!) : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _pickDocument,
                      child: const Text('اختيار ملف', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                    ),
                    if (_file != null) ...[
                      const SizedBox(height: 8),
                      Text('تم اختيار: ${_file!.name}', style: const TextStyle(fontSize: 14, color: textColor, fontFamily: 'Cairo')),
                    ],
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _handleUpload,
                      child: Text(
                        _isLoading ? 'جارٍ الرفع...' : 'رفع المحتوى',
                        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/home'),
                child: const Text('عودة', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
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
    super.dispose();
  }
}