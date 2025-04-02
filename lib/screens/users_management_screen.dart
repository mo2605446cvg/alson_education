import 'package:flutter/material.dart';
import 'package:alson_education/screens/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';

import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  Future<void> _uploadUsers() async {
    final result = await FilePicker.platform.pickFiles(allowedExtensions: ['xlsx'], type: FileType.custom);
    if (result != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final db = DatabaseService();
      final dbInstance = await db.database;

      for (var sheet in excel.tables.keys) {
        final rows = excel.tables[sheet]!.rows;
        for (var row in rows.skip(1)) { // تخطي العنوان
          final username = row[0]?.value.toString() ?? '';
          final password = row[1]?.value.toString() ?? '';
          final code = DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8);
          await dbInstance.insert('users', {
            'code': code,
            'username': username,
            'department': sheet,
            'role': 'user',
            'password': password,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع المستخدمين بنجاح', style: TextStyle(color: Colors.green))),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _uploadUsers,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
              child: const Text('رفع ملف Excel'),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseService().getUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('الكود')),
                        DataColumn(label: Text('اسم المستخدم')),
                        DataColumn(label: Text('القسم')),
                        DataColumn(label: Text('الدور')),
                        DataColumn(label: Text('كلمة المرور')),
                      ],
                      rows: snapshot.data!.map((user) => DataRow(cells: [
                        DataCell(Text(user['code'])),
                        DataCell(Text(user['username'])),
                        DataCell(Text(user['department'])),
                        DataCell(Text(user['role'])),
                        DataCell(Text(user['password'])),
                      ])).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}