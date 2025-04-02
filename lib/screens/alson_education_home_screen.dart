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
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(
              context,
              '/profile',
              arguments: currentUser,
            ),
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
            'الملف الشخصي',
            Icons.person,
            Colors.blue,
            () => Navigator.pushNamed(
              context,
              '/profile',
              arguments: currentUser,
            ),
          ),
          _buildDashboardItem(
            context,
            'المحتوى',
            Icons.folder,
            Colors.amber,
            () {},
          ),
          _buildDashboardItem(
            context,
            'الشات',
            Icons.chat,
            Colors.green,
            () {},
          ),
          _buildDashboardItem(
            context,
            'النتائج',
            Icons.assessment,
            Colors.purple,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
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
