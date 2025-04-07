import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/strings.dart';

class ResultsQueryScreen extends StatefulWidget {
  @override
  _ResultsQueryScreenState createState() => _ResultsQueryScreenState();
}

class _ResultsQueryScreenState extends State<ResultsQueryScreen> {
  final _studentIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('results', appState.language))),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(labelText: AppStrings.get('student_id', appState.language), border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/view_results'),
              child: Text(AppStrings.get('view_results', appState.language)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}