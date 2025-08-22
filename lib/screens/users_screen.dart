import 'package:flutter/material.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart';

class UsersScreen extends StatefulWidget {
  final ApiService apiService;

  UsersScreen({required this.apiService});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  final Map<String, TextEditingController> _fieldControllers = {
    'code': TextEditingController(),
    'username': TextEditingController(),
    'department': TextEditingController(),
    'division': TextEditingController(),
    'role': TextEditingController(),
    'password': TextEditingController(),
  };
  bool _isLoading = false;

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
        SnackBar(content: Text('فشل في جلب المستخدمين')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addUser() async {
    if (!_fieldControllers.values.every((controller) => controller.text.isNotEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال جميع الحقول')),
      );
      return;
    }

    try {
      final success = await widget.apiService.addUser(
        code: _fieldControllers['code']!.text,
        username: _fieldControllers['username']!.text,
        department: _fieldControllers['department']!.text,
        division: _fieldControllers['division']!.text,
        role: _fieldControllers['role']!.text,
        password: _fieldControllers['password']!.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة المستخدم بنجاح')),
        );
        
        // مسح الحقول
        _fieldControllers.values.forEach((controller) => controller.clear());
        _loadUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة المستخدم')),
      );
    }
  }

  Future<void> _deleteUser(User user) async {
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
        final success = await widget.apiService.deleteUser(user.code);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حذف المستخدم بنجاح')),
          );
          _loadUsers();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف المستخدم')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('إدارة المستخدمين',style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 20),
            
            // نموذج إضافة مستخدم
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (var entry in _fieldControllers.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: _getFieldLabel(entry.key),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: entry.key == 'password',
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _addUser,
                    child: Text('إضافة مستخدم'),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // قائمة المستخدمين
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('كود: ${user.code}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('الاسم: ${user.username}', style: TextStyle(color: Colors.grey)),
                                      Text('القسم: ${user.department}', style: TextStyle(color: Colors.grey)),
                                      Text('الشعبة: ${user.division}', style: TextStyle(color: Colors.grey)),
                                      Text('الدور: ${user.role}', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteUser(user),
                                  tooltip: 'حذف',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFieldLabel(String key) {
    switch (key) {
      case 'code': return 'كود المستخدم';
      case 'username': return 'اسم المستخدم';
      case 'department': return 'القسم';
      case 'division': return 'الشعبة';
      case 'role': return 'الدور';
      case 'password': return 'كلمة المرور';
      default: return key;
    }
  }

  @override
  void dispose() {
    _fieldControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}