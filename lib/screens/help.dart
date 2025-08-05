
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/colors.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBarWidget(isAdmin: user.role == 'admin'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'المساعدة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 384),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كيفية استخدام التطبيق',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 8),
                    Text('1. تسجيل الدخول باستخدام كود المستخدم وكلمة المرور.', style: TextStyle(fontSize: 16, color: textColor, fontFamily: 'Cairo')),
                    SizedBox(height: 8),
                    Text('2. عرض المحتوى التعليمي حسب القسم والشعبة.', style: TextStyle(fontSize: 16, color: textColor, fontFamily: 'Cairo')),
                    SizedBox(height: 8),
                    Text('3. التواصل عبر الشات (للأدمن فقط).', style: TextStyle(fontSize: 16, color: textColor, fontFamily: 'Cairo')),
                    SizedBox(height: 8),
                    Text('4. التحقق من النتائج في صفحة النتائج.', style: TextStyle(fontSize: 16, color: textColor, fontFamily: 'Cairo')),
                    SizedBox(height: 8),
                    Text('للدعم، تواصل مع إدارة الألسن أكاديمي.', style: TextStyle(fontSize: 16, color: textColor, fontFamily: 'Cairo')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/home'),
                child: const Text('عودة', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}