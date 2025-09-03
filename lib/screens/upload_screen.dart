import 'package:flutter/material.dart';
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
  final TextEditingController _fileUrlController = TextEditingController();
  bool _isUploading = false;

  Future<void> _uploadContent() async {
    if (_titleController.text.isEmpty ||
        _fileUrlController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال جميع الحقول')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final success = await widget.apiService.uploadContent(
        title: _titleController.text,
        fileUrl: _fileUrlController.text,
        uploadedBy: widget.user.username,
        description: _descriptionController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفع المحتوى بنجاح')),
        );
        
        // مسح الحقول
        _titleController.clear();
        _descriptionController.clear();
        _fileUrlController.clear();
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
        title: Text('إضافة محتوى جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('إضافة محتوى من رابط', style: Theme.of(context).textTheme.displayMedium),
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

                  // حقل رابط الملف
                  TextField(
                    controller: _fileUrlController,
                    decoration: InputDecoration(
                      labelText: 'رابط الملف من Supabase Storage *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.link),
                      hintText: 'https://hsgqgjkrbmkaxwhnktfv.supabase.co/storage/v1/object/public/content/filename.pdf',
                    ),
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
                  SizedBox(height: 20),

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
                              Text('إضافة المحتوى'),
                            ],
                          ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 16),

                  // معلومات مساعدة
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('كيفية الحصول على الرابط:', 
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('1. ارفع الملف إلى Supabase Storage'),
                          Text('2. انسخ الرابط العام للملف'),
                          Text('3. الصق الرابط في الحقل أعلاه'),
                        ],
                      ),
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
    _fileUrlController.dispose();
    super.dispose();
  }
}