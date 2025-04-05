import 'package:flutter/material.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/widgets/custom_appbar.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _feedbackController = TextEditingController();

  void _submitFeedback() {
    if (_feedbackController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال ملاحظاتك بنجاح', style: TextStyle(color: AppColors.successColor))),
      );
      _feedbackController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى كتابة ملاحظاتك', style: TextStyle(color: AppColors.errorColor))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'مركز المساعدة'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تواصلوا معنا', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('البريد: support@alson.edu'),
                      Text('الهاتف: 01023828155'),
                      Divider(),
                      Text('ساعات العمل: 8 صباحاً - 4 مساءً'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('شاركنا رأيك', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'اكتب ملاحظاتك هنا',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: Text('إرسال'),
                style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/home'),
                child: Text('عودة'),
                style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
