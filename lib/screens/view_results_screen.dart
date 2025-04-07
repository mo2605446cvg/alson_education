import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/strings.dart';

class ViewResultsScreen extends StatelessWidget {
  ViewResultsScreen({super.key}); // إزالة const هنا

  final Map<String, String> results = {
    'math': '85/100',
    'science': '92/100',
    'arabic': '88/100',
  };

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('results', appState.language)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${AppStrings.get('name', appState.language)}: ${appState.currentUserEmail}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...results.entries.map((e) => Text('${e.key}: ${e.value}', textAlign: TextAlign.center)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
