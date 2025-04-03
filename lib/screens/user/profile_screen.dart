import 'package:flutter/material.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/utils/colors.dart';
import '../home_screen.dart'; // استيراد من المجلد الأصلي
import '../../widgets/custom_appbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    user = User.fromMap(args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'الملف الشخصي', user: user.toMap()),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: 340,
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(children: [Icon(Icons.person, color: AppColors.primaryColor), Text('الاسم: ${user.username}', style: TextStyle(fontSize: 16, color: AppColors.textColor))]),
                    Row(children: [Icon(Icons.lock, color: AppColors.primaryColor), Text('الكود: ${user.code}', style: TextStyle(fontSize: 16, color: AppColors.textColor))]),
                    Row(children: [Icon(Icons.group, color: AppColors.primaryColor), Text('القسم: ${user.department}', style: TextStyle(fontSize: 16, color: AppColors.textColor))]),
                    Row(children: [Icon(Icons.security, color: AppColors.primaryColor), Text('الدور: ${user.role}', style: TextStyle(fontSize: 16, color: AppColors.textColor))]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home', arguments: user.toMap()),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(primary: AppColors.primaryColor, minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
