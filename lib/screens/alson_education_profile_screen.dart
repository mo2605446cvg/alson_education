import 'package:flutter/material.dart';
import 'package:alson_education/database/alson_education_database.dart';
import 'package:alson_education/models/alson_education_user.dart';

class AlsonEducationProfileScreen extends StatefulWidget {
  final String userCode;

  const AlsonEducationProfileScreen({super.key, required this.userCode});

  @override
  _AlsonEducationProfileScreenState createState() => _AlsonEducationProfileScreenState();
}

class _AlsonEducationProfileScreenState extends State<AlsonEducationProfileScreen> {
  late AlsonEducationUser _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final db = await AlsonEducationDatabase.instance.database;
    final user = await db.query(
      'users',
      where: 'code = ?',
      whereArgs: [widget.userCode],
    );
    
    if (user.isNotEmpty) {
      setState(() {
        _currentUser = AlsonEducationUser.fromMap(user.first);
        _usernameController.text = _currentUser.username;
        _departmentController.text = _currentUser.department;
        _passwordController.text = _currentUser.password;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final db = await AlsonEducationDatabase.instance.database;
    await db.update(
      'users',
      {
        'username': _usernameController.text,
        'department': _departmentController.text,
        'password': _passwordController.text,
      },
      where: 'code = ?',
      whereArgs: [_currentUser.code],
    );

    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      child: Text(
                        _currentUser.username[0],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileField('الكود الجامعي', _currentUser.code),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      controller: _usernameController,
                      label: 'اسم المستخدم',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      controller: _departmentController,
                      label: 'القسم',
                      icon: Icons.school,
                    ),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: const Text('حفظ التغييرات'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18)),
        const Divider(),
      ],
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        _isEditing
            ? TextFormField(
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(icon),
                ),
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
              )
            : Row(
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    isPassword ? '••••••••' : controller.text,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
        const Divider(),
      ],
    );
  }
}
