import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/colors.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('الألسن للعلوم الحديثة', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
        backgroundColor: PRIMARY_COLOR,
        leading: Icon(Icons.school, color: Colors.white, size: 30),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (String result) {
              if (result == 'logout') {
                appState.logout();
                Navigator.pushReplacementNamed(context, '/');
              } else {
                Navigator.pushNamed(context, '/$result');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'profile', child: Row(children: [Icon(Icons.person), Text('الملف الشخصي')])),
              PopupMenuItem<String>(value: 'results', child: Row(children: [Icon(Icons.grade), Text('النتيجة')])),
              PopupMenuItem<String>(value: 'content', child: Row(children: [Icon(Icons.folder), Text('المحتوى')])),
              PopupMenuItem<String>(value: 'chat', child: Row(children: [Icon(Icons.chat), Text('الشات')])),
              PopupMenuItem<String>(value: 'help', child: Row(children: [Icon(Icons.help), Text('المساعدة')])),
              PopupMenuItem<String>(value: 'logout', child: Row(children: [Icon(Icons.logout), Text('تسجيل الخروج')])),
              if (appState.isAdmin)
                PopupMenuItem<String>(value: 'admin/users', child: Row(children: [Icon(Icons.edit), Text('إدارة المستخدمين')])),
              if (appState.isAdmin)
                PopupMenuItem<String>(value: 'admin/upload', child: Row(children: [Icon(Icons.upload), Text('رفع المحتوى')])),
            ],
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: SECONDARY_COLOR,
        child: Column(
          children: [
            Text('مرحباً ${appState.currentUserEmail}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: PRIMARY_COLOR)),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text('جدول قسم ${appState.currentUserDepartment}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Image.asset('assets/img/po.jpg', width: 340, fit: BoxFit.cover),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/results'),
                  child: Text('عرض النتيجة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/content'),
                  child: Text('المحتوى'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ACCENT_COLOR,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/chat'),
                  child: Text('الشات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
