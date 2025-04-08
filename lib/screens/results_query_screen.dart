import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/strings.dart';

class ResultsQueryScreen extends StatefulWidget {
  const ResultsQueryScreen({super.key});

  @override
  State<ResultsQueryScreen> createState() => _ResultsQueryScreenState();
}

class _ResultsQueryScreenState extends State<ResultsQueryScreen> {
  final _studentIdController = TextEditingController();

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
                TextField(
                  controller: _studentIdController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('student_id', appState.language),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/view_results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(AppStrings.get('view_results', appState.language)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
