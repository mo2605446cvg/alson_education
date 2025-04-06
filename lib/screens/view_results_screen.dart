import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/colors.dart';

class ViewResultsScreen extends StatelessWidget {
  final Map<String, String> results = {
    'math': '85/100',
    'science': '92/100',
    'arabic': '88/100',
  };

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text('نتائج الامتحانات')),
      body: Container(
        padding: EdgeInsets.all(20),
        color: SECONDARY_COLOR,
        child: Column(
          children: [
            Text('نتائج الامتحانات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: PRIMARY_COLOR)),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: EdgeInsets.all(15),
                width: 340,
                child: Column(
                  children: [
                    Text('الاسم: ${appState.currentUserEmail}', style: TextStyle(color: TEXT_COLOR)),
                    Divider(),
                    Text('html: ${results['math']}', style: TextStyle(color: TEXT_COLOR)),
                    Text('Ai: ${results['science']}', style: TextStyle(color: TEXT_COLOR)),
                    Text('python: ${results['arabic']}', style: TextStyle(color: TEXT_COLOR)),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
