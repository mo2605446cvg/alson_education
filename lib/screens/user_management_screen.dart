import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:alson_education/database/database_helper.dart';
import 'package:alson_education/models/user.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    final users = await db.query('users');
    setState(() {
      _users = users.map((user) => User.fromMap(user)).toList();
      _isLoading = false;
    });
  }

  Future<void> _uploadExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final file = result.files.first;
        final excel = Excel.decodeBytes(file.bytes!);

        for (var table in excel.tables.keys) {
          final sheet = excel.tables[table]!;
          final department = table;

          for (var row in sheet.rows) {
            if (row.length >= 2) {
              await DatabaseHelper.createUser({
                'username': row[0]!.value.toString(),
                'department': department,
                'password': row[1]!.value.toString(),
              });
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم استيراد المستخدمين بنجاح')),
        );
        await _loadUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة المستخدمين')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.upload),
        onPressed: _uploadExcel,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) => _buildUserItem(_users[index]),
            ),
    );
  }

  Widget _buildUserItem(User user) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user.username),
        subtitle: Text('${user.department} - ${user.role}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editUser(user),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteUser(user.code),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editUser(User user) async {
    // Implement edit functionality
  }

  Future<void> _deleteUser(String code) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final db = await DatabaseHelper.instance.database;
      await db.delete('users', where: 'code = ?', whereArgs: [code]);
      await _loadUsers();
    }
  }
}