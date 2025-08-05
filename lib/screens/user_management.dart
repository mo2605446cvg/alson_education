
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/components/app_bar.dart';
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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _department = 'Math';
  String _division = 'Division A';
  String _role = 'user';
  List<User> _users = [];
  bool _isLoading = false;

  final List<String> departments = ['Math', 'Science', 'Computer', 'Physics', 'Chemistry'];
  final List<String> divisions = ['Division A', 'Division B'];
  final List<String> roles = ['admin', 'user'];

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
        const SnackBar(content: Text('فشل في جلب المستخدمين')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAddUser() async {
    if (_codeController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final newUser = User(
        code: _codeController.text,
        username: _usernameController.text,
        department: _department,
        division: _division,
        role: _role,
      );
      await addUser(newUser, _passwordController.text);
      _codeController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة المستخدم بنجاح')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إضافة المستخدم')),
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
                _fetchUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف المستخدم بنجاح')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في حذف المستخدم')),
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBarWidget(isAdmin: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'لوحة التحكم',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('إضافة مستخدم جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        hintText: 'كود المستخدم',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'اسم المستخدم',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _department,
                      items: departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                      onChanged: (value) => setState(() => _department = value!),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _division,
                      items: divisions.map((div) => DropdownMenuItem(value: div, child: Text(div, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                      onChanged: (value) => setState(() => _division = value!),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _role,
                      items: roles.map((role) => DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                      onChanged: (value) => setState(() => _role = value!),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _handleAddUser,
                      child: const Text('إضافة المستخدم', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('قائمة المستخدمين', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
              Expanded(
                child: _users.isEmpty
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                                    Text('كود: ${user.code}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                    Text('القسم: ${user.department}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                    Text('الشعبة: ${user.division}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                    Text('الدور: ${user.role}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}