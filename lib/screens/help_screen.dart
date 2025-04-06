import 'package:flutter/material.dart';
import 'package:alson_education/constants/colors.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مركز المساعدة')),
      body: Container(
        padding: EdgeInsets.all(20),
        color: SECONDARY_COLOR,
        child: Column(
          children: [
            Text('مركز المساعدة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: PRIMARY_COLOR)),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: EdgeInsets.all(15),
                width: 340,
                child: Column(
                  children: [
                    Text('تواصلوا معنا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TEXT_COLOR)),
                    Text('البريد: support@alson.edu', style: TextStyle(color: TEXT_COLOR)),
                    Text('الهاتف: 01023828155', style: TextStyle(color: TEXT_COLOR)),
                    Divider(),
                    Text('ساعات العمل: 8 صباحاً - 4 مساءً', style: TextStyle(color: TEXT_COLOR)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}