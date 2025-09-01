import 'package:flutter/material.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/models/content.dart';
import 'package:alson_education/screens/image_viewer_screen.dart';
import 'package:alson_education/screens/text_viewer_screen.dart';

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
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // منطق التمرير التلقائي
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final content = await widget.apiService.getContent('', '');
      setState(() => _content = content);
    } catch (e) {
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
      // فتح PDF في المتصفح
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
        final success = await widget.apiService.deleteContent(
          item.id,
          '',
          '',
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حذف المحتوى بنجاح')),
          );
          _loadContent();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف المحتوى')),
        );
      }
    }
  }

  Widget _buildFileIcon(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, size: 40, color: Colors.blue);
      case 'jpg':
      case 'png':
      case 'jpeg':
        return Icon(Icons.image, size: 40, color: Colors.green);
      case 'txt':
        return Icon(Icons.text_snippet, size: 40, color: Colors.orange);
      default:
        return Icon(Icons.insert_drive_file, size: 40, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text('المحتوى التعليمي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('المحتوى المتاح للجميع', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'بحث في المحتوى...',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      fillColor: Colors.grey[800],
                      filled: true,
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loadContent,
                  child: Text('تحديث'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : _content.isEmpty
                      ? Center(
                          child: Text(
                            'لا يوجد محتوى متاح حالياً',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _content.length,
                          itemBuilder: (context, index) {
                            final item = _content[index];
                            final searchTerm = _searchController.text.toLowerCase();
                            
                            if (searchTerm.isNotEmpty &&
                                !item.title.toLowerCase().contains(searchTerm) &&
                                !item.description.toLowerCase().contains(searchTerm)) {
                              return SizedBox.shrink();
                            }

                            return Card(
                              elevation: 3,
                              color: Colors.grey[900],
                              margin: EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: _buildFileIcon(item.fileType),
                                      onPressed: () => _viewContent(item),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.title, 
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                          SizedBox(height: 4),
                                          Text('نوع الملف: ${item.fileType}', style: TextStyle(color: Colors.white70)),
                                          Text('حجم الملف: ${item.formattedSize}', style: TextStyle(color: Colors.white70)),
                                          Text('تم الرفع بواسطة: ${item.uploadedBy}', style: TextStyle(color: Colors.white70)),
                                          Text('تاريخ الرفع: ${item.uploadDate}', style: TextStyle(color: Colors.white70)),
                                          SizedBox(height: 4),
                                          Text('نبذة: ${item.description}', 
                                              maxLines: 2, 
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: Colors.white70)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.visibility, color: Colors.blue),
                                          onPressed: () => _viewContent(item),
                                          tooltip: 'عرض',
                                        ),
                                        if (widget.user.role == 'admin')
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteContent(item),
                                            tooltip: 'حذف',
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
    );
  }
}
