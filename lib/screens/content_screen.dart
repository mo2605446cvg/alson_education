import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      final content = await widget.apiService.getContent();
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
      // فتح الملف في متصفح خارجي
      // يمكن استخدام package:url_launcher
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يمكنك فتح الملف من خلال المتصفح')),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildContentThumbnail(Content item) {
    if (['jpg', 'png', 'jpeg'].contains(item.fileType)) {
      // صورة - عرضها كبوستر
      return CachedNetworkImage(
        imageUrl: item.filePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: Icon(Icons.image, color: Colors.grey[400], size: 40),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40),
        ),
      );
    } else if (item.fileType == 'pdf') {
      // PDF - أيقونة مع لون مميز
      return Container(
        color: Colors.red[50],
        child: Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
      );
    } else {
      // ملفات أخرى
      return Container(
        color: Colors.blue[50],
        child: Icon(Icons.insert_drive_file, size: 40, color: Colors.blue),
      );
    }
  }

  Widget _buildContentCard(Content item) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () => _viewContent(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // البوستر/الأيقونة
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildContentThumbnail(item),
                ),
              ),
              
              SizedBox(width: 12),
              
              // معلومات المحتوى
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4),
                    
                    if (item.description.isNotEmpty)
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    SizedBox(height: 6),
                    
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          item.uploadedBy,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        
                        Spacer(),
                        
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          _formatDate(item.uploadDate),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المكتبة التعليمية'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث في المحتوى...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // عدد العناصر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'العناصر: ${_content.length}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // قائمة المحتوى
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _content.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'لا يوجد محتوى متاح',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadContent,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: _content.length,
                          itemBuilder: (context, index) {
                            final item = _content[index];
                            return _buildContentCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadContent,
        child: Icon(Icons.refresh),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}