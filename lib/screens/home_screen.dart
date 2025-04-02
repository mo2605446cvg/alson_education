import 'package:flutter/material.dart';
import 'package:alson_education/models/user.dart';

class HomeScreen extends StatelessWidget {
  final User currentUser; // Pass user data from login

  HomeScreen({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الصفحة الرئيسية'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('الملف الشخصي'),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ),
              if (currentUser.role == 'admin')
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.people),
                    title: Text('إدارة المستخدمين'),
                    onTap: () => Navigator.pushNamed(context, '/user-management'),
                  ),
                ),
              // Add more menu items...
            ],
          ),
        ],
      ),
      body: GridView.count(
        padding: EdgeInsets.all(20),
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
          // Add more items...
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
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}