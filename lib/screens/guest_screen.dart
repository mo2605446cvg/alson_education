import 'package:flutter/material.dart';
import 'package:alson_education/models/user.dart';

class GuestScreen extends StatelessWidget {
  final User user;
  final Function() onLogout;

  GuestScreen({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أكاديمية الألسن'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                "https://via.placeholder.com/200?text=Alson+Logo",
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                "مرحباً بك في أكاديمية الألسن",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "نبذة عن الأكاديمية",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "أكاديمية الألسن هي مؤسسة تعليمية رائدة متخصصة في تدريس اللغات والعلوم الإنسانية. نحن نقدم برامج تعليمية متميزة تلبي احتياجات سوق العمل وتواكب التطورات العالمية في مجال التعليم.",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الدراسة في الأكاديمية",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "تقدم الأكاديمية مجموعة متنوعة من البرامج الدراسية تشمل:\n\n"
                      "• برامج اللغة العربية لغير الناطقين بها\n"
                      "• برامج اللغة الإنجليزية\n"
                      "• برامج الترجمة واللغات\n"
                      "• برامج العلوم الإنسانية والاجتماعية\n"
                      "• دورات تدريبية متخصصة في مختلف المجالات",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "شروط الالتحاق",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "للالتحاق ببرامج الأكاديمية، يشترط:\n\n"
                      "• الحصول على شهادة الثانوية العامة أو ما يعادلها\n"
                      "• اجتياز اختبار القبول والمقابلة الشخصية\n"
                      "• توفر الرغبة الحقيقية في التعلم والتطوير\n"
                      "• الالتزام بأنظمة ولوائح الأكاديمية",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "معلومات التواصل",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "للاستفسار عن البرامج وشروط الالتحاق:\n\n"
                      "• الهاتف: 0123456789\n"
                      "• البريد الإلكتروني: info@alalsun.edu\n"
                      "• العنوان: شارع الجامعة، المدينة التعليمية\n"
                      "• أوقات العمل: من الأحد إلى الخميس، 8 صباحاً - 4 مساءً",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: onLogout,
                child: Text("تسجيل الدخول كعضو"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}