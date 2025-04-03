import 'package:flutter/material.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/utils/colors.dart';
import 'profile_screen.dart';
import 'content_screen.dart';
import 'chat_screen.dart';
import 'results_screen.dart';
import 'help_screen.dart';
import 'admin/admin_dashboard.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/dashboard_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    user = User.fromMap(args);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';

    return Scaffold(
      appBar: CustomAppBar(title: 'الألسن للعلوم الحديثة', isAdmin: isAdmin, user: user.toMap()),
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
            if (isAdmin) SizedBox(height: 20),
            if (isAdmin)
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/admin/dashboard'),
                child: Text('لوحة التحكم الإدارية'),
                style: ElevatedButton.styleFrom(primary: AppColors.primaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
