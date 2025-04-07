import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/strings.dart';

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
      appBar: AppBar(title: Text(AppStrings.get('results', appState.language))),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('${AppStrings.get('name', appState.language)}: ${appState.currentUserEmail}'),
            ...results.entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
          ],
        ),
      ),
    );
  }
}