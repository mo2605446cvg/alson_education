import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  List<User> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await getUsers();
      setState(() => _users = data);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في جلب المستخدمين: تأكد من الاتصال بالإنترنت')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAddUser(String code, String username, String password, String department, String division, String role) async {
    setState(() => _isLoading = true);
    try {
      final newUser = User(
        code: code,
        username: username,
        department: department,
        division: division,
        role: role,
      );
      await addUser(newUser, password);
      await _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة المستخدم بنجاح')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إضافة المستخدم: تأكد من الاتصال بالإنترنت')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteUser(String code) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف هذا المستخدم؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await deleteUser(code);
                await _fetchUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف المستخدم بنجاح')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في حذف المستخدم: تأكد من الاتصال بالإنترنت')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final _codeController = TextEditingController();
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    final _departmentController = TextEditingController();
    final _divisionController = TextEditingController();
    String _role = 'student';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مستخدم جديد', style: TextStyle(fontFamily: 'Cairo')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'كود المستخدم', hintStyle: TextStyle(fontFamily: 'Cairo')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(hintText: 'اسم المستخدم', hintStyle: TextStyle(fontFamily: 'Cairo')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: 'كلمة المرور', hintStyle: TextStyle(fontFamily: 'Cairo')),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(hintText: 'القسم', hintStyle: TextStyle(fontFamily: 'Cairo')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _divisionController,
                decoration: const InputDecoration(hintText: 'الشعبة', hintStyle: TextStyle(fontFamily: 'Cairo')),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _role,
                onChanged: (value) => _role = value!,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('طالب', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'admin', child: Text('أدمن', style: TextStyle(fontFamily: 'Cairo'))),
                ],
                decoration: const InputDecoration(hintText: 'الدور', hintStyle: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () {
              _handleAddUser(
                _codeController.text,
                _usernameController.text,
                _passwordController.text,
                _departmentController.text,
                _divisionController.text,
                _role,
              );
              Navigator.pop(context);
            },
            child: const Text('إضافة', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;
    if (user.role != 'admin') {
      return Scaffold(
        appBar: AppBarWidget(isAdmin: false),
        body: const Center(
          child: Text('غير مصرح لك بإدارة المستخدمين', style: TextStyle(fontFamily: 'Cairo')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarWidget(isAdmin: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'إدارة المستخدمين',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('تحديث المستخدمين', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? const Center(child: Text('لا يوجد مستخدمين', style: TextStyle(color: textColor, fontFamily: 'Cairo')))
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                                        Text('الكود: ${user.code}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                        Text('القسم: ${user.department}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                        Text('الشعبة: ${user.division}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                        Text('الدور: ${user.role}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _handleDeleteUser(user.code),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _showAddUserDialog,
              child: const Text('إضافة مستخدم جديد', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }
}
