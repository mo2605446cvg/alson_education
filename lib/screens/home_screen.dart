import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final isAdmin = user?['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الألسن للعلوم الحديثة', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') Navigator.pushReplacementNamed(context, '/login');
              else Navigator.pushNamed(context, value);
            },
            itemBuilder: (context) {
              var items = [
                const PopupMenuItem(value: '/profile', child: Text('الملف الشخصي')),
                const PopupMenuItem(value: '/results', child: Text('النتيجة')),
                const PopupMenuItem(value: '/content', child: Text('المحتوى')),
                const PopupMenuItem(value: '/chat', child: Text('الشات')),
                const PopupMenuItem(value: '/help', child: Text('المساعدة')),
                const PopupMenuItem(value: 'logout', child: Text('تسجيل الخروج')),
              ];
              if (isAdmin) {
                items.insert(0, const PopupMenuItem(value: '/users_management', child: Text('إدارة المستخدمين')));
                items.insert(1, const PopupMenuItem(value: '/upload_content', child: Text('رفع المحتوى')));
              }
              return items;
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('مرحباً ${user?['username']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 20),
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text('جدول قسم ${user?['department']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Image.asset('assets/img/po.jpg', width: 340),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/results'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
                  child: const Text('عرض النتيجة'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/content'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600], foregroundColor: Colors.white),
                  child: const Text('المحتوى'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/chat', arguments: user),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white),
                  child: const Text('الشات'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}