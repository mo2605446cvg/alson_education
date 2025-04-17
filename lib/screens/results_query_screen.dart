import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:alson_education/widgets/app_bar_widget.dart';

class ResultsQueryScreen extends StatefulWidget {
  const ResultsQueryScreen({super.key});

  @override
  State<ResultsQueryScreen> createState() => _ResultsQueryScreenState();
}

class _ResultsQueryScreenState extends State<ResultsQueryScreen> {
  final _studentIdController = TextEditingController();

  void _navigateToResults(BuildContext context) {
    if (_studentIdController.text.isNotEmpty) {
      Navigator.pushNamed(context, '/view_results');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter student ID')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: CustomAppBar(AppStrings.get('results', appState.language)),
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
                  onPressed: () => _navigateToResults(context),
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
