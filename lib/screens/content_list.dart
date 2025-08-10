import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/models/content.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}


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
    FirebaseMessaging.instance.subscribeToTopic('all_users');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.notification?.body ?? 'محتوى جديد')),
      );
      _fetchContent();
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _fetchContent();
  }

  Future<void> _fetchContent() async {
  setState(() => _isLoading = true);
  try {
    final data = await getContent();
    setState(() => _content = data);
  } catch (error) {
    print('Error in _fetchContent: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل في جلب المحتوى: $error')),
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

  Future<void> _openContent(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح الملف')),
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
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: primaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
                                ),
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
                                    const SizedBox(height: 8),
                                    Text(
                                      'النبذة: ${content.description.isEmpty ? 'غير متوفر' : content.description}',
                                      style: const TextStyle(color: textColor, fontFamily: 'Cairo'),
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
                                    const SizedBox(height: 8),
                                    if (content.fileType == 'jpg' || content.fileType == 'png' || content.fileType == 'jpeg')
                                      CachedNetworkImage(
                                        imageUrl: 'http://ki74.alalsunacademy.com/${content.filePath}',
                                        height: 200,
                                        placeholder: (context, url) => const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      )
                                    else if (content.fileType == 'txt')
                                      Container(
                                        height: 200,
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          content.description.isEmpty ? 'محتوى المقال غير متوفر' : content.description,
                                          style: const TextStyle(fontFamily: 'Cairo'),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 5,
                                        ),
                                      )
                                    else if (content.fileType == 'pdf')
                                      ElevatedButton(
                                        onPressed: () => _openContent('http://ki74.alalsunacademy.com/${content.filePath}'),
                                        child: const Text('فتح ملف PDF', style: TextStyle(fontFamily: 'Cairo')),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.download, color: primaryColor),
                                          onPressed: () => _openContent('http://ki74.alalsunacademy.com/${content.filePath}'),
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
