import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('النتائج')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('نتائج الطالب', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            DataTable(
              columns: [
                DataColumn(label: Text('المادة')),
                DataColumn(label: Text('الدرجة')),
              ],
              rows: [
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