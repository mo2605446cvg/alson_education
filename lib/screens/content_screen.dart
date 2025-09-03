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
  String _selectedDepartment = 'الكل';
  String _selectedDivision = 'الكل';

  final List<String> _departments = ['الكل', 'قسم اللغة العربية', 'قسم اللغة الإنجليزية', 'قسم الترجمة', 'قسم العلوم الإنسانية'];
  final List<String> _divisions = ['الكل', 'الشعبة أ', 'الشعبة ب', 'الشعبة ج', 'الشعبة د'];

  @override
  void initState() {
    super.initState();
    _loadContent();
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
      // للملفات الأخرى، فتح في متصفح
      // يمكن استخدام package:url_launcher
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
    return _content.where((item) {
      final matchesDepartment = _selectedDepartment == 'الكل' || 
          item.department == _selectedDepartment;
      final matchesDivision = _selectedDivision == 'الكل' || 
          item.division == _selectedDivision;
      final searchTerm = _searchController.text.toLowerCase();
      final matchesSearch = searchTerm.isEmpty ||
          item.title.toLowerCase().contains(searchTerm) ||
          item.description.toLowerCase().contains(searchTerm);

      return matchesDepartment && matchesDivision && matchesSearch;
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
            
            // فلاتر القسم والشعبة
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: InputDecoration(
                      labelText: 'القسم',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    items: _departments.map((String department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(department, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDepartment = newValue!;
                      });
                    },
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDivision,
                    decoration: InputDecoration(
                      labelText: 'الشعبة',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    items: _divisions.map((String division) {
                      return DropdownMenuItem<String>(
                        value: division,
                        child: Text(division, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDivision = newValue!;
                      });
                    },
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            
            // شريط البحث
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
            
            // إحصائيات
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
                              if (_searchController.text.isNotEmpty || 
                                  _selectedDepartment != 'الكل' || 
                                  _selectedDivision != 'الكل')
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _selectedDepartment = 'الكل';
                                      _selectedDivision = 'الكل';
                                    });
                                  },
                                  child: Text('إعادة تعيين الفلاتر', style: TextStyle(color: Colors.blue)),
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
                                              if (item.department.isNotEmpty)
                                                Text('القسم: ${item.department}', style: TextStyle(color: Colors.white70)),
                                              if (item.division.isNotEmpty)
                                                Text('الشعبة: ${item.division}', style: TextStyle(color: Colors.white70)),
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
}