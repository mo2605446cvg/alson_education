import 'package:flutter/material.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
      ),
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
                    Row(children: [Icon(Icons.person, color: AppColors.primaryColor), Text('الاسم: ${user['username']}', style: TextStyle(fontSize: 16, color: AppColors.textColor))]),
                    Row(children: [Icon(Icons.lock, color: AppColors.primaryColor), Text('الكود: ${user['code']}', style: TextStyle(fontSize: 16, color: AppColors.textColor))]),
                    Row(children: [Icon(Icons.group, color: AppColors.primaryColor), Text('القسم: ${user['department']}', style: TextStyle(fontSize: 16, color: AppColors.textColor))]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home', arguments: user),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(primary: AppColors.primaryColor, minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
