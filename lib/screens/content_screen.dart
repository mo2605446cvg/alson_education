import 'package:flutter/material.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/models/content.dart';
import 'package:alson_education/screens/image_viewer_screen.dart';
import 'package:alson_education/screens/text_viewer_screen.dart';
import 'package:alson_education/screens/pdf_viewer_screen.dart';

class ContentScreen extends StatefulWidget {
  final ApiService apiService;
  final app_user.AppUser user;

  ContentScreen({required this.apiService, required this.user});

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  List<Content> _content = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      print('جلب المحتوى...');
      final content = await widget.apiService.getContent();
      print('تم جلب ${content.length} عنصر محتوى');
      
      setState(() => _content = content);
    } catch (e) {
      print('فشل في جلب المحتوى: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب المحتوى: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _viewContent(Content item) {
    final url = item.filePath;
    
    if (item.fileType == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(pdfUrl: url),
        ),
      );
    } else if (['jpg', 'png', 'jpeg'].contains(item.fileType)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(imageUrl: url),
        ),
      );
    } else if (item.fileType == 'txt') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextViewerScreen(textUrl: url),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يمكنك فتح الملف من خلال المتصفح')),
      );
    }
  }

  Future<void> _deleteContent(Content item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        content: Text('هل أنت متأكد من حذف هذا المحتوى؟', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await widget.apiService.deleteContent(item.id);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حذف المحتوى بنجاح')),
          );
          _loadContent();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف المحتوى: $e')),
        );
      }
    }
  }

  Widget _buildFileIcon(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, size: 40, color: Colors.red);
      case 'jpg':
      case 'png':
      case 'jpeg':
        return Icon(Icons.image, size: 40, color: Colors.green);
      case 'txt':
        return Icon(Icons.text_snippet, size: 40, color: Colors.orange);
      case 'mp4':
        return Icon(Icons.videocam, size: 40, color: Colors.purple);
      case 'mp3':
        return Icon(Icons.audiotrack, size: 40, color: Colors.blue);
      default:
        return Icon(Icons.insert_drive_file, size: 40, color: Colors.grey);
    }
  }

  List<Content> _getFilteredContent() {
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      return _content;
    }
    
    return _content.where((item) {
      return item.title.toLowerCase().contains(searchTerm) ||
             item.description.toLowerCase().contains(searchTerm) ||
             item.uploadedBy.toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredContent = _getFilteredContent();

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text('المكتبة التعليمية', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('المكتبة الرقمية - المحتوى المتاح', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 20),
            
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'بحث في المحتوى...',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                fillColor: Colors.grey[800],
                filled: true,
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 10),
            
            Card(
              color: Colors.grey[800],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('المجموع: ${_content.length}', style: TextStyle(color: Colors.white)),
                    Text('المعروض: ${filteredContent.length}', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : filteredContent.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, size: 64, color: Colors.white70),
                              SizedBox(height: 16),
                              Text(
                                'لا يوجد محتوى متاح حالياً',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              if (_searchController.text.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  child: Text('إعادة تعيين البحث', style: TextStyle(color: Colors.blue)),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: filteredContent.length,
                          itemBuilder: (context, index) {
                            final item = filteredContent[index];

                            return Card(
                              elevation: 3,
                              color: Colors.grey[900],
                              margin: EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: _buildFileIcon(item.fileType),
                                          onPressed: () => _viewContent(item),
                                          iconSize: 40,
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.title, 
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                              SizedBox(height: 4),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline, size: 16, color: Colors.white70),
                                        SizedBox(width: 4),
                                        Text('نوع الملف: ${item.fileType.toUpperCase()}', style: TextStyle(color: Colors.white70)),
                                        SizedBox(width: 16),
                                        Icon(Icons.storage, size: 16, color: Colors.white70),
                                        SizedBox(width: 4),
                                        Text('الحجم: ${item.formattedSize}', style: TextStyle(color: Colors.white70)),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 16, color: Colors.white70),
                                        SizedBox(width: 4),
                                        Text('المرسل: ${item.uploadedBy}', style: TextStyle(color: Colors.white70)),
                                        SizedBox(width: 16),
                                        Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                                        SizedBox(width: 4),
                                        Text('التاريخ: ${item.uploadDate}', style: TextStyle(color: Colors.white70)),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    if (item.description.isNotEmpty)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('الوصف:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                                          Text(item.description, 
                                              style: TextStyle(color: Colors.white70)),
                                        ],
                                      ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _viewContent(item),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.visibility, size: 16),
                                              SizedBox(width: 4),
                                              Text('عرض المحتوى'),
                                            ],
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue[700],
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        if (widget.user.role == 'admin')
                                          SizedBox(width: 8),
                                        if (widget.user.role == 'admin')
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteContent(item),
                                            tooltip: 'حذف المحتوى',
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadContent,
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue[700],
        tooltip: 'تحديث المحتوى',
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}