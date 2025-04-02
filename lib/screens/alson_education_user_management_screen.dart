import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:alson_education/database/alson_education_database.dart';
import 'package:alson_education/models/alson_education_user.dart';
import 'package:uuid/uuid.dart';

class AlsonEducationUserManagementScreen extends StatefulWidget {
  const AlsonEducationUserManagementScreen({super.key});

  @override
  _AlsonEducationUserManagementScreenState createState() => _AlsonEducationUserManagementScreenState();
}

class _AlsonEducationUserManagementScreenState extends State<AlsonEducationUserManagementScreen> {
  List<AlsonEducationUser> _users = [];
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    _users = await AlsonEducationDatabase.getAllUsers();
    setState(() => _isLoading = false);
  }

  Future<void> _uploadExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    setState(() => _isLoading = true);
    try {
      final file = result.files.first;
      final excel = Excel.decodeBytes(file.bytes!);

      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        for (final row in sheet.rows) {
          if (row.length >= 2) {
            await AlsonEducationDatabase.createUser(
              AlsonEducationUser(
                code: _uuid.v4().substring(0, 8),
                username: row[0]!.value.toString(),
                department: table,
                role: 'user',
                password: row[1]!.value.toString(),
              ),
            );
          }
        }
      }
      await _loadUsers();
      _showSuccess('تم استيراد المستخدمين بنجاح');
    } catch (e) {
      _showError('حدث خطأ: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload),
        onPressed: _uploadExcel,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) => _buildUserItem(_users[index]),
            ),
    );
  }

  Widget _buildUserItem(AlsonEducationUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user.username),
        subtitle: Text('${user.department} - ${user.role}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editUser(user),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteUser(user.code),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editUser(AlsonEducationUser user) async {
    // تنفيذ واجهة التعديل هنا
  }

  Future<void> _deleteUser(String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final db = await AlsonEducationDatabase.instance.database;
        await db.delete('users', where: 'code = ?', whereArgs: [code]);
        await _loadUsers();
        _showSuccess('تم حذف المستخدم بنجاح');
      } catch (e) {
        _showError('حدث خطأ أثناء الحذف: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
