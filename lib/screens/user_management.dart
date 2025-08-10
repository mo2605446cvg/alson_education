
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'user';
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
        SnackBar(content: Text('فشل في جلب المستخدمين: $error', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addUser() async {
    if (_codeController.text.isEmpty || _nameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول', style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final newUser = User(
        id: '', // سيتم تعيينه بواسطة الخادم
        code: _codeController.text,
        name: _nameController.text,
        role: _role,
      );
      await addUser(newUser, _passwordController.text);
      await _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة المستخدم بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
      );
      _codeController.clear();
      _nameController.clear();
      _passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة المستخدم: $e', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String id) async {
    setState(() => _isLoading = true);
    try {
      await deleteUser(id);
      await _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المستخدم بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حذف المستخدم: $e', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'كود المستخدم', hintStyle: TextStyle(fontFamily: 'Cairo')),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم', hintStyle: TextStyle(fontFamily: 'Cairo')),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور', hintStyle: TextStyle(fontFamily: 'Cairo')),
                obscureText: true,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              DropdownButton<String>(
                value: _role,
                onChanged: (value) => setState(() => _role = value!),
                items: ['user', 'admin'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(fontFamily: 'Cairo')));
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addUser,
                child: const Text('إضافة مستخدم', style: TextStyle(fontFamily: 'Cairo')),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _users.isEmpty
                        ? const Center(child: Text('لا توجد مستخدمين', style: TextStyle(fontFamily: 'Cairo')))
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return ListTile(
                                title: Text(user.name, style: const TextStyle(fontFamily: 'Cairo')),
                                subtitle: Text('كود: ${user.code} - دور: ${user.role}', style: const TextStyle(fontFamily: 'Cairo')),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteUser(user.id),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}