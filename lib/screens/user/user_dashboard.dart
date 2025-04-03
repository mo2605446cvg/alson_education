import 'package:flutter/material.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/utils/colors.dart';
import '../profile_screen.dart';
import '../content_screen.dart';
import '../chat_screen.dart';
import '../results_screen.dart';
import '../help_screen.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/dashboard_card.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
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
      appBar: CustomAppBar(title: 'لوحة التحكم للمستخدم', user: user.toMap()),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('مرحباً ${user.username}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            DashboardCard(
              title: 'جدول قسم ${user.department}',
              child: Image.asset('assets/img/po.jpg', width: 340, fit: BoxFit.cover),
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
                  onPressed: () => Navigator.pushNamed(context, '/chat', arguments: user.toMap()),
                  child: Text('الشات'),
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile', arguments: user.toMap()),
              child: Text('الملف الشخصي'),
              style: ElevatedButton.styleFrom(primary: AppColors.primaryColor),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/help'),
              child: Text('المساعدة'),
              style: ElevatedButton.styleFrom(primary: AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
