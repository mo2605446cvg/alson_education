import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentScreen extends StatelessWidget {
  Future<List<Content>> loadContents() async {
    final db = await DatabaseService.instance.database;
    final result = await db.query('content');
    return result.map((json) => Content.fromMap(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Content>>(
      future: loadContents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final contents = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text('المحتوى التعليمي')),
          body: Container(
            padding: EdgeInsets.all(20),
            color: SECONDARY_COLOR,
            child: Column(
              children: [
                if (contents.isEmpty)
                  Text('لا يوجد محتوى متاح حالياً', style: TextStyle(color: Colors.grey)),
                Expanded(
                  child: ListView.builder(
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final content = contents[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          title: Text(content.title),
                          subtitle: Text('نوع الملف: ${content.fileType}, تاريخ الرفع: ${content.uploadDate}'),
                          onTap: () async {
                            if (await canLaunch(content.filePath)) {
                              await launch(content.filePath);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الملف غير موجود')));
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('عودة'),
                  style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}