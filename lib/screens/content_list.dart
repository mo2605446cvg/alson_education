
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentList extends StatefulWidget {
  const ContentList({super.key});

  @override
  _ContentListState createState() => _ContentListState();
}

class _ContentListState extends State<ContentList> {
  List<Content> _content = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    setState(() => _isLoading = true);
    try {
      final data = await getContent();
      setState(() => _content = data);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب المحتوى: $error', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteContent(String id) async {
    setState(() => _isLoading = true);
    try {
      await deleteContent(id);
      await _fetchContent();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المحتوى بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حذف المحتوى: $e', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openContent(String filePath) async {
    final url = filePath.startsWith('http') ? filePath : '$baseUrl/$filePath';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح الملف', style: TextStyle(fontFamily: 'Cairo'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBarWidget(isAdmin: user.role == 'admin'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _content.isEmpty
                ? const Center(child: Text('لا يوجد محتوى', style: TextStyle(fontFamily: 'Cairo')))
                : ListView.builder(
                    itemCount: _content.length,
                    itemBuilder: (context, index) {
                      final content = _content[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(content.title, style: const TextStyle(fontFamily: 'Cairo')),
                          subtitle: Text(
                            '${content.description}\n${content.uploadDate}',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          trailing: user.role == 'admin'
                              ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteContent(content.id),
                                )
                              : null,
                          onTap: () => _openContent(content.filePath),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}