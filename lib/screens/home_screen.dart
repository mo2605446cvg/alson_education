import 'package:flutter/material.dart';
import 'package:alson_education/utils/colors.dart';
import 'profile_screen.dart';
import 'content_screen.dart';
import 'chat_screen.dart';
import 'results_screen.dart';
import 'help_screen.dart';
import 'admin/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text('الألسن للعلوم الحديثة', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        leading: Icon(Icons.school, color: Colors.white, size: 30),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (String result) {
              switch (result) {
                case 'profile':
                  Navigator.pushNamed(context, '/profile', arguments: user);
                  break;
                case 'results':
                  Navigator.pushNamed(context, '/results');
                  break;
                case 'content':
                  Navigator.pushNamed(context, '/content');
                  break;
                case 'chat':
                  Navigator.pushNamed(context, '/chat', arguments: user);
                  break;
                case 'help':
                  Navigator.pushNamed(context, '/help');
                  break;
                case 'logout':
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 'manageUsers':
                  Navigator.pushNamed(context, '/admin/users');
                  break;
                case 'uploadContent':
                  Navigator.pushNamed(context, '/admin/content');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (isAdmin) PopupMenuItem<String>(value: 'manageUsers', child: Text('إدارة المستخدمين')),
              if (isAdmin) PopupMenuItem<String>(value: 'uploadContent', child: Text('رفع المحتوى')),
              PopupMenuItem<String>(value: 'profile', child: Text('الملف الشخصي')),
              PopupMenuItem<String>(value: 'results', child: Text('النتيجة')),
              PopupMenuItem<String>(value: 'content', child: Text('المحتوى')),
              PopupMenuItem<String>(value: 'chat', child: Text('الشات')),
              PopupMenuItem<String>(value: 'help', child: Text('المساعدة')),
              PopupMenuItem<String>(value: 'logout', child: Text('تسجيل الخروج')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('مرحباً ${user['username']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text('جدول قسم ${user['department']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  style: ElevatedButton.styleFrom(primary: AppColors.primaryColor),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/content'),
                  child: Text('المحتوى'),
                  style: ElevatedButton.styleFrom(primary: AppColors.accentColor),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/chat', arguments: user),
                  child: Text('الشات'),
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
