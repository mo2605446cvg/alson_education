
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';

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
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      final data = await getContent(user.department, user.division);
      setState(() => _content = data);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في جلب المحتوى')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteContent(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف هذا المحتوى؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await deleteContent(id);
                _fetchContent();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف المحتوى بنجاح')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في حذف المحتوى')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOpenContent(String filePath) async {
    final url = 'https://ki74.alalsunacademy.com/api/$filePath';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في فتح الملف')),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'المحتوى',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _content.isEmpty
                    ? const Center(child: Text('لا يوجد محتوى', style: TextStyle(color: textColor, fontFamily: 'Cairo')))
                    : ListView.builder(
                        itemCount: _content.length,
                        itemBuilder: (context, index) {
                          final content = _content[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _handleOpenContent(content.filePath),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(content.title, style: const TextStyle(fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                                        Text('النوع: ${content.fileType}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                        Text(
                                          'تاريخ الرفع: ${DateFormat('dd/MM/yyyy', 'ar').format(DateTime.parse(content.uploadDate))}',
                                          style: const TextStyle(color: textColor, fontFamily: 'Cairo'),
                                        ),
                                        Text('بواسطة: ${content.uploadedBy}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                      ],
                                    ),
                                  ),
                                ),
                                if (user.role == 'admin')
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _handleDeleteContent(content.id),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/content_upload'),
                child: const Text('رفع محتوى جديد', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}