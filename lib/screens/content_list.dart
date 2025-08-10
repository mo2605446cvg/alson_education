import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/models/content.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:alson_education/screens/image_viewer_screen.dart';
import 'package:alson_education/screens/text_viewer_screen.dart';

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
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    FirebaseMessaging.instance.subscribeToTopic('${user.department}_${user.division}');
  }

  Future<void> _fetchContent() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      final data = await getContent(user.department, user.division);
      setState(() => _content = data);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في جلب المحتوى: تأكد من الاتصال بالإنترنت')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteContent(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo'), textAlign: TextAlign.center),
        content: const Text('هل أنت متأكد من حذف هذا المحتوى؟', style: TextStyle(fontFamily: 'Cairo'), textAlign: TextAlign.center),
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
                await _fetchContent();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف المحتوى بنجاح')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في حذف المحتوى: تأكد من الاتصال بالإنترنت')),
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _fetchContent,
                  child: const Text('تحديث المحتوى', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _content.isEmpty
                        ? const Center(child: Text('لا توجد محتويات', style: TextStyle(color: textColor, fontFamily: 'Cairo')))
                        : ListView.builder(
                            itemCount: _content.length,
                            itemBuilder: (context, index) {
                              final content = _content[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: primaryColor, width: 2),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            content.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                              fontFamily: 'Cairo',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            'نوع الملف: ${content.fileType}',
                                            style: const TextStyle(color: textColor, fontFamily: 'Cairo'),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            'تم الرفع بواسطة: ${content.uploadedBy}',
                                            style: const TextStyle(color: textColor, fontFamily: 'Cairo'),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            'تاريخ الرفع: ${content.uploadDate}',
                                            style: const TextStyle(color: textColor, fontFamily: 'Cairo'),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            'نبذة: ${content.description}',
                                            style: const TextStyle(color: textColor, fontFamily: 'Cairo'),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility, color: primaryColor),
                                          onPressed: () {
                                            final url = 'https://ki74.alalsunacademy.com/${content.filePath}';
                                            if (content.fileType == 'pdf') {
                                              Navigator.push(
                                                context,
                                                
                                                ),
                                              );
                                            } else if (['jpg', 'png', 'jpeg'].contains(content.fileType)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ImageViewerScreen(url: url),
                                                ),
                                              );
                                            } else if (content.fileType == 'txt') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => TextViewerScreen(url: url),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        if (user.role == 'admin')
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _handleDeleteContent(content.id),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}