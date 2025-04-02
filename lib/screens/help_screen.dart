import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مركز المساعدة', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text('تواصلوا معنا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('البريد: support@alson.edu', style: TextStyle(fontSize: 14)),
                    Text('الهاتف: 01023828155', style: TextStyle(fontSize: 14)),
                    Divider(),
                    Text('ساعات العمل: 8 صباحاً - 4 مساءً', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
              child: const Text('عودة'),
            ),
          ],
        ),
      ),
    );
  }
}