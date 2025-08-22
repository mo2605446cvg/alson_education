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
  bool _showAddUserForm = false; // التحكم في إظهار نموذج إضافة المستخدم

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
        
        // مسح الحقول وإخفاء النموذج
        _fieldControllers.values.forEach((controller) => controller.clear());
        setState(() => _showAddUserForm = false);
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

  Widget _buildAddUserForm() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إضافة مستخدم جديد',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _addUser,
                  child: Text('إضافة'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _showAddUserForm = false);
                  },
                  child: Text('إلغاء'),
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
      appBar: AppBar(
        title: Text('إدارة المستخدمين'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('إدارة المستخدمين', style: Theme.of(context).textTheme.displayMedium),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _showAddUserForm = !_showAddUserForm);
                  },
                  child: Text(_showAddUserForm ? 'إخفاء النموذج' : 'إضافة مستخدم'),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            if (_showAddUserForm) _buildAddUserForm(),
            if (_showAddUserForm) SizedBox(height: 20),
            
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? Center(
                          child: Text(
                            'لا يوجد مستخدمين مسجلين',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(user.username, style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('كود: ${user.code} - الدور: ${user.role}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteUser(user),
                                  tooltip: 'حذف',
                                ),
                                onTap: () {
                                  // يمكن إضافة تفاصيل المستخدم عند النقر
                                },
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