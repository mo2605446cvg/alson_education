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
      print('Loaded ${users.length} users from database');
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
      print('Error loading users: $e');
    }
  }

  Future<void> uploadExcelFile() async {
    try {
      print('Starting Excel file upload...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file selected')));
        print('No file selected');
        return;
      }

      final filePath = result.files.single.path!;
      print('File selected: $filePath');

      final bytes = await File(filePath).readAsBytes();
      print('File bytes read successfully, length: ${bytes.length}');

      final excel = Excel.decodeBytes(bytes);
      print('Excel file decoded, sheets: ${excel.sheets.keys}');

      final db = DatabaseService.instance;
      int totalUsersAdded = 0;

      for (var sheet in excel.sheets.keys) {
        final sheetData = excel.sheets[sheet];
        if (sheetData == null || sheetData.rows.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sheet is empty')));
          print('Sheet "$sheet" is empty');
          continue;
        }

        final department = sheet; // اسم الورقة هو القسم
        print('Processing sheet: $department');

        int nameIndex = -1;
        int codeIndex = -1;

        // التعامل مع الصف الأول كصف العناوين مباشرة
        final headerRow = sheetData.rows[0];
        print('Raw Header Row 0: ${headerRow.map((cell) => cell?.value.toString() ?? 'null').join(', ')}');

        for (int i = 0; i < headerRow.length; i++) {
          final rawValue = headerRow[i]?.value?.toString() ?? '';
          final cleanedValue = rawValue
              .trim() // إزالة المسافات من البداية والنهاية
              .replaceAll(RegExp(r'\s+'), ' ') // استبدال المسافات المتعددة بمسافة واحدة
              .replaceAll(RegExp(r'[-_\u2000-\u200B]+'), '') // إزالة الشرطات والمسافات غير المرئية
              .replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), '') // إزالة الرموز غير الأبجدية
              .toLowerCase(); // تحويل إلى أحرف صغيرة لتسهيل التطابق

          print('Cell [0][$i] - Raw Value: $rawValue, Cleaned Value: $cleanedValue');
          if (cleanedValue.contains('الاســـــــم')) {
            nameIndex = i;
          } else if (cleanedValue.contains('كود') || cleanedValue.contains('الطالب') || cleanedValue.contains('code')) {
            codeIndex = i;
          }
        }

        // التحقق من العثور على العناوين
        if (nameIndex == -1 || codeIndex == -1) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not find "الاســـــــم" and "كود الطالب" in the header row')));
          print('Headers not found in row 0. nameIndex=$nameIndex, codeIndex=$codeIndex');
          return;
        }

        print('Headers found: nameIndex=$nameIndex, codeIndex=$codeIndex');

        // قراءة البيانات من الصف التالي لصف العناوين فصاعدًا
        for (int rowIndex = 1; rowIndex < sheetData.rows.length; rowIndex++) {
          final row = sheetData.rows[rowIndex];
          if (row.isEmpty || row.length <= nameIndex || row.length <= codeIndex || row[nameIndex] == null || row[codeIndex] == null) {
            print('Skipping empty or invalid row at index $rowIndex: $row');
            continue; // تجاهل الصفوف الفارغة أو الناقصة
          }

          final username = row[nameIndex]?.value?.toString().trim() ?? '';
          final password = row[codeIndex]?.value?.toString().trim() ?? '';
          final code = password; // استخدام كود الطالب كـ code

          print('Processing row $rowIndex - Username: $username, Password/Code: $password');

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
            print('User added: ${user.username}, Code: ${user.code}');
          } else {
            print('Invalid data in row $rowIndex: Username or Password is empty');
          }
        }
      }

      if (totalUsersAdded > 0) {
        await loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$totalUsersAdded users uploaded successfully')));
        print('Successfully uploaded $totalUsersAdded users');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid users found in the Excel file')));
        print('No valid users found');
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
