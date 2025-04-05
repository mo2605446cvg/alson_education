import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/services/notification_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/utils/theme.dart';
import 'package:alson_education/screens/user/profile_screen.dart';
import 'package:alson_education/screens/content_screen.dart';
import 'package:alson_education/screens/chat_screen.dart';
import 'package:alson_education/screens/results_screen.dart';
import 'package:alson_education/screens/help_screen.dart';
import 'package:alson_education/screens/admin/admin_dashboard.dart';
import 'package:alson_education/widgets/custom_appbar.dart';
import 'package:alson_education/widgets/dashboard_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User user;
  int points = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    user = args != null ? User.fromMap(args) : User(code: 'guest', username: 'Guest', department: 'غير محدد', role: 'user', password: '');
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final db = DatabaseService.instance;
    points = await db.getPoints(user.code);
    setState(() {});
    if (points >= 50) {
      await NotificationService().showNotification('مكافأة!', 'لقد حصلت على مكافأة لتجميع $points نقطة!');
    }
  }

  Future<void> _earnPoints(String action) async {
    final db = DatabaseService.instance;
    await db.addPoints(user.code, 10); // 10 نقاط لكل نشاط
    await NotificationService().scheduleSmartNotification(user.code, action);
    await _loadPoints();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'الألسن للعلوم الحديثة',
        isAdmin: isAdmin,
        user: user.toMap(),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('مرحباً ${user.username}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Chip(
                    label: Text('النقاط: $points'),
                    backgroundColor: AppColors.successColor,
                  ),
                ],
              ),
              SizedBox(height: 20),
              DashboardCard(
                title: 'جدول قسم ${user.department}',
                child: Image.asset('assets/img/po.jpg', width: double.infinity, fit: BoxFit.cover, height: 200),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildButton(context, 'عرض النتيجة', '/results', 'فتح النتائج'),
                  _buildButton(context, 'المحتوى', '/content', 'عرض المحتوى'),
                  _buildButton(context, 'الشات', '/chat', 'بدء محادثة', arguments: user.toMap()),
                  if (isAdmin) _buildButton(context, 'لوحة التحكم', '/admin/dashboard', 'فتح لوحة التحكم'),
                ],
              ),
              if (points >= 50) ...[
                SizedBox(height: 20),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('تهانينا! لقد حصلت على مكافأة لتجميع $points نقطة!', style: TextStyle(color: AppColors.successColor)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, String route, String action, {Map<String, dynamic>? arguments}) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () async {
          await _earnPoints(action);
          Navigator.pushNamed(context, route, arguments: arguments);
        },
        child: Text(title),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
