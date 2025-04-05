import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'dart:async';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alson_education/widgets/custom_appbar.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  List<Map<String, dynamic>> contents = const [];
  List<Map<String, dynamic>> filteredContents = const [];
  late StreamController<List<Map<String, dynamic>>> _streamController;
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _loadContents();
    _startContentPolling();
  }

  Future<void> _loadContents() async {
    final db = DatabaseService.instance;
    final fetchedContents = await db.query('content');
    _streamController.add(fetchedContents);
    setState(() {
      contents = fetchedContents;
      filteredContents = fetchedContents;
      _isLoading = false;
    });
  }

  void _startContentPolling() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (mounted) await _loadContents();
    });
  }

  void _filterContents(String query) {
    setState(() {
      filteredContents = contents.where((content) {
        return content['title'].toLowerCase().contains(query.toLowerCase()) ||
            content['file_type'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _shareContent(Map<String, dynamic> content) async {
    final filePath = content['file_path'];
    final file = File(filePath);
    if (await file.exists()) {
      await Share.shareFiles([filePath], text: 'تحقق من هذا المحتوى: ${content['title']}');
    } else {
      await Share.share('تحقق من هذا المحتوى: ${content['title']}');
    }
  }

  Future<void> _launchFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن فتح الملف', style: TextStyle(color: AppColors.errorColor))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الملف غير موجود', style: TextStyle(color: AppColors.errorColor))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'المحتوى التعليمي'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ابحث في المحتوى',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onChanged: _filterContents,
            ),
            SizedBox(height: 10),
            _isLoading
                ? _buildSkeletonLoader()
                : Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('لا يوجد محتوى متاح حاليًا'));
                        }
                        return ListView.builder(
                          itemCount: filteredContents.length,
                          itemBuilder: (context, index) => _buildContentItem(filteredContents[index]),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentItem(Map<String, dynamic> content) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(content['title'], style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نوع الملف: ${content['file_type']}'),
            Text('تاريخ الرفع: ${content['upload_date']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.share, color: AppColors.accentColor),
              onPressed: () => _shareContent(content),
            ),
            ElevatedButton(
              onPressed: () => _launchFile(content['file_path']),
              child: Text('عرض'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SpinKitPulse(color: AppColors.primaryColor, size: 50),
              SizedBox(height: 10),
              SpinKitThreeBounce(color: AppColors.accentColor, size: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _streamController.close();
    super.dispose();
  }
}
