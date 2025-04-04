import 'package:flutter/material.dart';
import 'package:alson_education/utils/colors.dart';
import 'homepackage:alson_education/screens/home_screen.dart';
import 'package:alson_education/widgets/custom_appbar.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _studentIdController = TextEditingController();

  void _showResults() {
    if (_studentIdController.text.isNotEmpty) {
      Navigator.pushNamed(context, '/show_results');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال رقم الجلوس', style: TextStyle(color: Colors.red))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'استعلام النتائج'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: 340,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: _studentIdController,
                      decoration: InputDecoration(labelText: 'رقم الجلوس', prefixIcon: Icon(Icons.numbers), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                      keyboardType: TextInputType.number,
                    ),
                    Text('تأكد من إدخال رقم الجلوس الصحيح', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showResults,
              child: Text('عرض النتيجة'),
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

class ShowResultsScreen extends StatelessWidget {
  const ShowResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = {"math": "85/100", "science": "92/100", "arabic": "88/100"};

    return Scaffold(
      appBar: CustomAppBar(title: 'نتائج الامتحانات'),
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
                    Text('الاسم: User', style: TextStyle(fontSize: 16, color: AppColors.textColor)),
                    Divider(),
                    Text('html: ${results['math']}', style: TextStyle(fontSize: 14, color: AppColors.textColor)),
                    Text('Ai: ${results['science']}', style: TextStyle(fontSize: 14, color: AppColors.textColor)),
                    Text('python: ${results['arabic']}', style: TextStyle(fontSize: 14, color: AppColors.textColor)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('عودة'),
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
