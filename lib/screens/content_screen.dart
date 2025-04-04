import 'package:flutter/material.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:alson_education/widgets/custom_appbar.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  List<Map<String, dynamic>> contents = [];
  late StreamController<List<Map<String, dynamic>>> _streamController;

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
    setState(() => contents = fetchedContents);
  }

  void _startContentPolling() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      final db = DatabaseService.instance;
      final updatedContents = await db.query('content');
      if (mounted) {
        _streamController.add(updatedContents);
        setState(() => contents = updatedContents);
      }
    });
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
      backgroundColor: AppColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('لا يوجد محتوى متاح حاليًا', style: TextStyle(fontSize: 16, color: AppColors.textColor)),
              );
            }

            final contents = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final content = contents[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('العنوان: ${content['title']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor)),
                              SizedBox(height: 5),
                              Text('نوع الملف: ${content['file_type']}', style: TextStyle(fontSize: 14, color: AppColors.textColor)),
                              SizedBox(height: 5),
                              Text('تاريخ الرفع: ${content['upload_date']}', style: TextStyle(fontSize: 14, color: AppColors.textColor)),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () => _launchFile(content['file_path']),
                                child: Text('عرض', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                  child: Text('عودة', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    minimumSize: Size(200, 50),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
