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
    final db = DatabaseService.instance;
    users = await db.getUsers();
    setState(() {});
  }

  Future<void> uploadExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final bytes = File(filePath).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final db = DatabaseService.instance;
      for (var sheet in excel.sheets.keys) {
        final sheetData = excel.sheets[sheet];
        if (sheetData == null) continue;

        final department = sheet; // اسم الورقة هو القسم
        for (var row in sheetData.rows.skip(1)) { // تخطي العنوان إذا كان موجودًا
          if (row.length >= 2) {
            final username = row[0]?.value?.toString() ?? '';
            final password = row[1]?.value?.toString() ?? '';
            final code = DateTime.now().millisecondsSinceEpoch.toString(); // كود فريد

            if (username.isNotEmpty && password.isNotEmpty) {
              final user = User(
                code: code,
                username: username,
                department: department,
                role: 'user',
                password: password,
              );
              await db.insertUser(user);
            }
          }
        }
      }
      await loadUsers(); // تحديث قائمة المستخدمين
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Users uploaded successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload Excel file')));
    }
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
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              title: Text(user.username, textAlign: TextAlign.center),
                              subtitle: Text('${user.code} - ${user.department}', textAlign: TextAlign.center),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await DatabaseService.instance.deleteUser(user.code);
                                  loadUsers();
                                },
                              ),
                            );
                          },
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
