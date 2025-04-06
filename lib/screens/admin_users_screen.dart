import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/constants/colors.dart';

class AdminUsersScreen extends StatefulWidget {
  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final db = await DatabaseService.instance.database;
    final result = await db.query('users');
    setState(() {
      users = result.map((json) => User.fromMap(json)).toList();
    });
  }

  Future<void> uploadUsers(FilePickerResult? result) async {
    if (result != null && result.files.single.path != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تحميل المستخدمين غير مدعوم حالياً')));
    }
  }

  void viewUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المستخدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الكود: ${user.code}'),
            Text('الاسم: ${user.username}'),
            Text('القسم: ${user.department}'),
            Text('الدور: ${user.role}'),
            Text('كلمة المرور: ${user.password}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('إغلاق'))],
      ),
    );
  }

  void editUser(User user) {}

  void deleteUser(String code) async {
    final db = await DatabaseService.instance.database;
    await db.delete('users', where: 'code = ?', whereArgs: [code]);
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة المستخدمين')),
      body: Container(
        padding: EdgeInsets.all(20),
        color: SECONDARY_COLOR,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(allowedExtensions: ['xlsx']);
                uploadUsers(result);
              },
              child: Text('رفع ملف Excel'),
              style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR, foregroundColor: Colors.white),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.username),
                    subtitle: Text('كود: ${user.code}, القسم: ${user.department}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.visibility), onPressed: () => viewUser(user)),
                        IconButton(icon: Icon(Icons.edit), onPressed: () => editUser(user)),
                        IconButton(icon: Icon(Icons.delete), onPressed: () => deleteUser(user.code)),
                      ],
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