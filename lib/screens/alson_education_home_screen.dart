import 'package:flutter/material.dart';
import 'package:alson_education/models/alson_education_user.dart';

class AlsonEducationHomeScreen extends StatelessWidget {
  final AlsonEducationUser currentUser;

  const AlsonEducationHomeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('الملف الشخصي'),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ),
              if (currentUser.role == 'admin')
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('إدارة المستخدمين'),
                    onTap: () => Navigator.pushNamed(context, '/user-management'),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildDashboardItem(
            context,
            'المحتوى التعليمي',
            Icons.folder,
            Colors.blue,
            '/content',
          ),
          _buildDashboardItem(
            context,
            'الشات',
            Icons.chat,
            Colors.green,
            '/chat',
          ),
          _buildDashboardItem(
            context,
            'النتائج',
            Icons.assessment,
            Colors.orange,
            '/results',
          ),
          _buildDashboardItem(
            context,
            'المساعدة',
            Icons.help,
            Colors.purple,
            '/help',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}