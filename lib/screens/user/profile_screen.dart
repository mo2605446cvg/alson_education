import 'package:flutter/material.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/widgets/custom_appbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      _handleError('لا توجد بيانات مستخدم');
      return;
    }
    try {
      user = User.fromMap(args);
      setState(() => _isLoading = false);
    } catch (e) {
      _handleError('خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: AppColors.errorColor))),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.secondaryColor,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'الملف الشخصي', user: user.toMap()),
      backgroundColor: AppColors.secondaryColor,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.person, color: AppColors.primaryColor),
                      SizedBox(width: 10),
                      Text('الاسم: ${user.username}', style: TextStyle(fontSize: 16, color: AppColors.textColor)),
                    ]),
                    SizedBox(height: 10),
                    Row(children: [
                      Icon(Icons.lock, color: AppColors.primaryColor),
                      SizedBox(width: 10),
                      Text('الكود: ${user.code}', style: TextStyle(fontSize: 16, color: AppColors.textColor)),
                    ]),
                    SizedBox(height: 10),
                    Row(children: [
                      Icon(Icons.group, color: AppColors.primaryColor),
                      SizedBox(width: 10),
                      Text('القسم: ${user.department}', style: TextStyle(fontSize: 16, color: AppColors.textColor)),
                    ]),
                    SizedBox(height: 10),
                    Row(children: [
                      Icon(Icons.security, color: AppColors.primaryColor),
                      SizedBox(width: 10),
                      Text('الدور: ${user.role}', style: TextStyle(fontSize: 16, color: AppColors.textColor)),
                    ]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/home', arguments: user.toMap());
                }
              },
              child: Text('عودة', style: TextStyle(color: Colors.white)),
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
