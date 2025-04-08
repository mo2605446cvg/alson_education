import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/constants/strings.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final db = DatabaseService.instance;
      users = await db.getUsers();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  Future<void> uploadExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file selected')));
        return;
      }

      final filePath = result.files.single.path!;
      final bytes = await File(filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final db = DatabaseService.instance;
      int totalUsersAdded = 0;

      for (var sheet in excel.sheets.keys) {
        final sheetData = excel.sheets[sheet];
        if (sheetData == null || sheetData.rows.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sheet is empty')));
          continue;
        }

        final department = sheet; // اسم الورقة هو القسم
        final headers = sheetData.rows[0]; // الصف الأول يحتوي على العناوين
        int nameIndex = -1;
        int codeIndex = -1;

        // البحث عن موقع العناوين في الصف الأول
        for (int i = 0; i < headers.length; i++) {
          final headerValue = headers[i]?.value?.toString().trim();
          if (headerValue == null) continue;

          // التعامل مع النصوص العربية والإنجليزية
          final lowerHeader = headerValue.toLowerCase();
          if (lowerHeader == 'الاسم' || lowerHeader == 'name') {
            nameIndex = i;
          } else if (lowerHeader == 'كود الطالب' || lowerHeader == 'student code') {
            codeIndex = i;
          }
        }

        // التحقق من وجود العناوين المطلوبة
        if (nameIndex == -1 || codeIndex == -1) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Excel file must contain "الاسم" and "كود الطالب" headers')));
          return;
        }

        // قراءة البيانات من الصف الثاني فصاعدًا
        for (var row in sheetData.rows.skip(1)) {
          if (row.isEmpty || row[nameIndex] == null || row[codeIndex] == null) continue; // تجاهل الصفوف الفارغة

          final username = row[nameIndex]?.value?.toString().trim() ?? '';
          final password = row[codeIndex]?.value?.toString().trim() ?? '';
          final code = password; // استخدام كود الطالب كـ code

          if (username.isNotEmpty && password.isNotEmpty) {
            final user = User(
              code: code,
              username: username,
              department: department,
              role: 'user',
              password: password,
            );
            await db.insertUser(user);
            totalUsersAdded++;
          }
        }
      }

      if (totalUsersAdded > 0) {
        await loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$totalUsersAdded users uploaded successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid users found in the Excel file')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading Excel file: $e')));
      print('Excel upload error: $e');
    }
  }

  Future<void> editUser(User user) async {
    final _editUsernameController = TextEditingController(text: user.username);
    final _editDepartmentController = TextEditingController(text: user.department);
    final _editPasswordController = TextEditingController(text: user.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editUsernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _editDepartmentController,
              decoration: const InputDecoration(labelText: 'Department'),
            ),
            TextField(
              controller: _editPasswordController,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = User(
                code: user.code,
                username: _editUsernameController.text.trim(),
                department: _editDepartmentController.text.trim(),
                role: user.role,
                password: _editPasswordController.text.trim(),
              );
              await DatabaseService.instance.updateUser(updatedUser);
              Navigator.pop(context);
              await loadUsers();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('admin_users', appState.language)),
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
                ElevatedButton(
                  onPressed: uploadExcelFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Upload Excel File'),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get('admin_users', appState.language),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                users.isEmpty
                    ? const Text('No users found', textAlign: TextAlign.center)
                    : SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Code')),
                              DataColumn(label: Text('Username')),
                              DataColumn(label: Text('Department')),
                              DataColumn(label: Text('Role')),
                              DataColumn(label: Text('Password')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: users.map((user) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(user.code)),
                                  DataCell(Text(user.username)),
                                  DataCell(Text(user.department)),
                                  DataCell(Text(user.role)),
                                  DataCell(Text(user.password)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => editUser(user),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            await DatabaseService.instance.deleteUser(user.code);
                                            loadUsers();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
