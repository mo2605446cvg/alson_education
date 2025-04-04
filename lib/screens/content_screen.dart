import 'package:flutter/material.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/widgets/custom_appbar.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  List<Map<String, dynamic>> contents = []; // تغيير إلى قائمة فارغة مبدئيًا

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    final db = DatabaseService.instance;
    contents = await db.query('content');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'المحتوى التعليمي'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (contents.isEmpty)
              Text('لا يوجد محتوى متاح حاليًا', style: TextStyle(fontSize: 16, color: Colors.grey)),
            if (contents.isNotEmpty)
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
                          children: [
                            Text('العنوان: ${content['title']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('نوع الملف: ${content['file_type']}', style: TextStyle(fontSize: 14)),
                            Text('تاريخ الرفع: ${content['upload_date']}', style: TextStyle(fontSize: 14)),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('عرض الملف غير مدعوم حاليًا')));
                              },
                              child: Text('عرض'),
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
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
