import 'package:flutter/material.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart'; // استيراد صحيح
import 'package:alson_education/screens/admin/user_management.dart'; // تعديل الاستيراد
import 'package:alson_education/screens/admin/content_management.dart';
import 'package:alson_education/widgets/custom_appbar.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'لوحة التحكم الإدارية'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/users'),
              child: Text('إدارة المستخدمين'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: Size(200, 50),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/content'),
              child: Text('رفع المحتوى'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: Size(200, 50),
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
