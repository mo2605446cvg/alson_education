import 'package:flutter/material.dart';
import 'package:alson_education/utils/colors.dart';
import 'home_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مركز المساعدة', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
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
                    Text('تواصلوا معنا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColor)),
                    Text('البريد: support@alson.edu', style: TextStyle(fontSize: 14, color: AppColors.textColor)),
                    Text('الهاتف: 01023828155', style: TextStyle(fontSize: 14, color: AppColors.textColor)),
                    Divider(),
                    Text('ساعات العمل: 8 صباحاً - 4 مساءً', style: TextStyle(fontSize: 14, color: AppColors.textColor)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(primary: AppColors.primaryColor, minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
