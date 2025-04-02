import 'package:flutter/material.dart';

class AlsonEducationResultsScreen extends StatelessWidget {
  const AlsonEducationResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('النتائج')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('نتائج الطالب', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            DataTable(
              columns: const [
                DataColumn(label: Text('المادة')),
                DataColumn(label: Text('الدرجة')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('اللغة العربية')),
                  DataCell(Text('85/100')),
                ]),
                DataRow(cells: [
                  DataCell(Text('الرياضيات')),
                  DataCell(Text('92/100')),
                ]),
                DataRow(cells: [
                  DataCell(Text('العلوم')),
                  DataCell(Text('88/100')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}