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

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final content = await widget.apiService.getContent(
        widget.user.department,
        widget.user.division,
      );
      setState(() => _content = content);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
        title: Text('تأكيد الحذف', textAlign: TextAlign.center),
        content: Text('هل أنت متأكد من حذف هذا المحتوى؟', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
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
          widget.user.department,
          widget.user.division,
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
        return Icon(Icons.picture_as_pdf, size: 40, color: Theme.of(context).colorScheme.primary);
      case 'jpg':
      case 'png':
      case 'jpeg':
        return Icon(Icons.image, size: 40, color: Theme.of(context).colorScheme.primary);
      case 'txt':
        return Icon(Icons.text_snippet, size: 40, color: Theme.of(context).colorScheme.primary);
      default:
        return Icon(Icons.insert_drive_file, size: 40, color: Theme.of(context).colorScheme.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('المحتوى', style: Theme.of(context).textTheme.displayMedium),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'بحث في المحتوى...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loadContent,
                  child: Text('تحديث المحتوى'),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _content.length,
                      itemBuilder: (context, index) {
                        final item = _content[index];
                        final searchTerm = _searchController.text.toLowerCase();
                        
                        if (searchTerm.isNotEmpty &&
                            !item.title.toLowerCase().contains(searchTerm)) {
                          return SizedBox.shrink();
                        }

                        return Card(
                          elevation: 3,
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
                                      Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('نوع الملف: ${item.fileType}', style: TextStyle(color: Colors.grey)),
                                      Text('حجم الملف: ${item.formattedSize}', style: TextStyle(color: Colors.grey)),
                                      Text('تم الرفع بواسطة: ${item.uploadedBy}', style: TextStyle(color: Colors.grey)),
                                      Text('تاريخ الرفع: ${item.uploadDate}', style: TextStyle(color: Colors.grey)),
                                      Text('نبذة: ${item.description}', maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.visibility),
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