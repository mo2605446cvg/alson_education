import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _studentIdController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('استعلام النتائج', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'رقم الجلوس',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_studentIdController.text.isNotEmpty) {
                  Navigator.pushNamed(context, '/results_view');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال رقم الجلوس', style: TextStyle(color: Colors.red))),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
              child: const Text('عرض النتيجة'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsViewScreen extends StatelessWidget {
  const ResultsViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final results = {'math': '85/100', 'science': '92/100', 'arabic': '88/100'};

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائج الامتحانات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text('الاسم: ${user?['username']}', style: const TextStyle(fontSize: 16)),
                    const Divider(),
                    Text('HTML: ${results['math']}', style: const TextStyle(fontSize: 14)),
                    Text('AI: ${results['science']}', style: const TextStyle(fontSize: 14)),
                    Text('Python: ${results['arabic']}', style: const TextStyle(fontSize: 14)),
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