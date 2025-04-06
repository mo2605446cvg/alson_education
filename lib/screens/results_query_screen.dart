import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/colors.dart';

class ResultsQueryScreen extends StatefulWidget {
  @override
  _ResultsQueryScreenState createState() => _ResultsQueryScreenState();
}

class _ResultsQueryScreenState extends State<ResultsQueryScreen> {
  final _studentIdController = TextEditingController();

  void showResults(BuildContext context) {
    if (_studentIdController.text.isNotEmpty) {
      Navigator.pushNamed(context, '/view_results');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال رقم الجلوس')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('استعلام النتائج')),
      body: Container(
        padding: EdgeInsets.all(20),
        color: SECONDARY_COLOR,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: EdgeInsets.all(10),
                width: 340,
                child: Column(
                  children: [
                    TextField(
                      controller: _studentIdController,
                      decoration: InputDecoration(labelText: 'رقم الجلوس', prefixIcon: Icon(Icons.numbers), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                    ),
                    Text('تأكد من إدخال رقم الجلوس الصحيح', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => showResults(context),
              child: Text('عرض النتيجة'),
              style: ElevatedButton.styleFrom(primary: PRIMARY_COLOR, onPrimary: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}