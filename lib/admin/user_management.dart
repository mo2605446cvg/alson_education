import 'package:flutter/material.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/widgets/excel_uploader.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = DatabaseService.instance;
    users = await db.query('users');
    setState(() {});
  }

  void _deleteUser(String code) async {
    final db = DatabaseService.instance;
    await db.delete('users', 'code = ?', [code]);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'إدارة المستخدمين', isAdmin: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ExcelUploader(onUploadSuccess: _loadUsers),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user['username']),
                    subtitle: Text('كود: ${user['code']} - القسم: ${user['department']} - الدور: ${user['role']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(user['code']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
