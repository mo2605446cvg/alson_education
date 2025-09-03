import 'package:flutter/material.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart' as app_user;

class UsersScreen extends StatefulWidget {
  final ApiService apiService;

  UsersScreen({required this.apiService});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<app_user.AppUser> _users = [];
  final Map<String, TextEditingController> _fieldControllers = {
    'code': TextEditingController(),
    'username': TextEditingController(),
    'role': TextEditingController(),
    'password': TextEditingController(),
  };
  bool _isLoading = false;
  bool _showAddUserForm = false;
  String? _selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await widget.apiService.getUsers();
      setState(() => _users = users);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب المستخدمين: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addUser() async {
    if (_fieldControllers['code']!.text.isEmpty ||
        _fieldControllers['username']!.text.isEmpty ||
        _fieldControllers['password']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال الحقول الإلزامية')),
      );
      return;
    }

    try {
      final success = await widget.apiService.addUser(
        code: _fieldControllers['code']!.text,
        username: _fieldControllers['username']!.text,
        role: _selectedRole!,
        password: _fieldControllers['password']!.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة المستخدم بنجاح')),
        );
        
        _fieldControllers.values.forEach((controller) => controller.clear());
        setState(() {
          _showAddUserForm = false;
          _selectedRole = 'user';
        });
        _loadUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة المستخدم: $e')),
      );
    }
  }

  Widget _buildAddUserForm() {
    return Card(
      elevation: 3,
      color: Colors.grey[900],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إضافة مستخدم جديد',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 20),
            
            TextField(
              controller: _fieldControllers['code'],
              decoration: InputDecoration(
                labelText: 'كود المستخدم *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            
            TextField(
              controller: _fieldControllers['username'],
              decoration: InputDecoration(
                labelText: 'اسم المستخدم *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'الدور *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              items: [
                DropdownMenuItem<String>(
                  value: 'user',
                  child: Text('مستخدم عادي', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'admin',
                  child: Text('مدير', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() => _selectedRole = newValue);
              },
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            
            TextField(
              controller: _fieldControllers['password'],
              decoration: InputDecoration(
                labelText: 'كلمة المرور *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              style: TextStyle(color: Colors.white),
              obscureText: true,
            ),
            SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _addUser,
                  child: Text('إضافة مستخدم'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _showAddUserForm = false);
                    _fieldControllers.values.forEach((controller) => controller.clear());
                  },
                  child: Text('إلغاء', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text('إدارة المستخدمين', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showAddUserForm) _buildAddUserForm(),
            if (_showAddUserForm) SizedBox(height: 20),
            
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : _users.isEmpty
                      ? Center(
                          child: Text('لا يوجد مستخدمين مسجلين',
                              style: TextStyle(color: Colors.white70, fontSize: 16)),
                        )
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return Card(
                              color: Colors.grey[900],
                              margin: EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(user.username,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                subtitle: Text('كود: ${user.code} - الدور: ${user.role == 'admin' ? 'مدير' : 'مستخدم'}',
                                    style: TextStyle(color: Colors.white70)),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteUser(user),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showAddUserForm = !_showAddUserForm),
        child: Icon(_showAddUserForm ? Icons.close : Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Future<void> _deleteUser(app_user.AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف', textAlign: TextAlign.center),
        content: Text('هل أنت متأكد من حذف هذا المستخدم؟', textAlign: TextAlign.center),
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
      try {
        await widget.apiService.deleteUser(user.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف المستخدم بنجاح')),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف المستخدم: $e')),
        );
      }
    }
  }
}