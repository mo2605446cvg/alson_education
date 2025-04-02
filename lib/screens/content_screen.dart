import 'package:flutter/material.dart';
import 'package:alson_education/screens/database.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحتوى التعليمي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseService().getContent(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                if (snapshot.data!.isEmpty) return const Text('لا يوجد محتوى متاح حاليًا');
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final content = snapshot.data![index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text('العنوان: ${content['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('نوع الملف: ${content['file_type']}'),
                              Text('تاريخ الرفع: ${content['upload_date']}'),
                              ElevatedButton(
                                onPressed: () {}, // يمكن إضافة منطق لفتح الملف باستخدام مكتبة مثل open_file
                                child: const Text('عرض'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
              child: const Text('عودة'),
            ),
          ],
        ),
      ),
    );
  }
}