import 'package:flutter/material.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late List<Map<String, dynamic>> contents;

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
      appBar: AppBar(
        title: Text('المحتوى التعليمي', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
      ),
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
                                // افتراضيًا، يمكن فتح الملف إذا كان موجودًا
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
              style: ElevatedButton.styleFrom(primary: AppColors.primaryColor, minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
