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
    'department': TextEditingController(),
    'division': TextEditingController(),
    'role': TextEditingController(),
    'password': TextEditingController(),
  };
  bool _isLoading = false;
  bool _showAddUserForm = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  String? _selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listScrollController.dispose();
    _fieldControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
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
    if (_fieldControllers['code']!.text.isEmpty ||
        _fieldControllers['username']!.text.isEmpty ||
        _fieldControllers['password']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال الحقول الإلزامية (الكود، الاسم، كلمة المرور)')),
      );
      return;
    }

    try {
      final success = await widget.apiService.addUser(
        code: _fieldControllers['code']!.text,
        username: _fieldControllers['username']!.text,
        department: _fieldControllers['department']!.text,
        division: _fieldControllers['division']!.text,
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

  Future<void> _deleteUser(app_user.AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        content: Text('هل أنت متأكد من حذف هذا المستخدم؟', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: Colors.blue)),
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
          SnackBar(content: Text('فشل في حذف المستخدم: $e')),
        );
      }
    }
  }

  Widget _buildAddUserForm() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Card(
        elevation: 3,
        color: Colors.grey[900],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إضافة مستخدم جديد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              
              // حقل الكود
              TextField(
                controller: _fieldControllers['code'],
                decoration: InputDecoration(
                  labelText: 'كود المستخدم *',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  prefixIcon: Icon(Icons.code, color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              
              // حقل الاسم
              TextField(
                controller: _fieldControllers['username'],
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم *',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  prefixIcon: Icon(Icons.person, color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              
              // اختيار القسم
              DropdownButtonFormField<String>(
                value: _fieldControllers['department']!.text.isEmpty ? null : _fieldControllers['department']!.text,
                decoration: InputDecoration(
                  labelText: 'القسم',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[800],
                  prefixIcon: Icon(Icons.category, color: Colors.white70),
                ),
                items: ['', 'قسم اللغة العربية', 'قسم اللغة الإنجليزية', 'قسم الترجمة', 'قسم العلوم الإنسانية']
                    .map((String department) {
                  return DropdownMenuItem<String>(
                    value: department.isEmpty ? null : department,
                    child: Text(department.isEmpty ? 'لا يوجد' : department, 
                        style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  _fieldControllers['department']!.text = newValue ?? '';
                },
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              
              // اختيار الشعبة
              DropdownButtonFormField<String>(
                value: _fieldControllers['division']!.text.isEmpty ? null : _fieldControllers['division']!.text,
                decoration: InputDecoration(
                  labelText: 'الشعبة',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[800],
                  prefixIcon: Icon(Icons.group, color: Colors.white70),
                ),
                items: ['', 'الشعبة أ', 'الشعبة ب', 'الشعبة ج', 'الشعبة د']
                    .map((String division) {
                  return DropdownMenuItem<String>(
                    value: division.isEmpty ? null : division,
                    child: Text(division.isEmpty ? 'لا يوجد' : division, 
                        style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  _fieldControllers['division']!.text = newValue ?? '';
                },
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              
              // اختيار الدور
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'الدور *',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[800],
                  prefixIcon: Icon(Icons.security, color: Colors.white70),
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
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              
              // حقل كلمة المرور
              TextField(
                controller: _fieldControllers['password'],
                decoration: InputDecoration(
                  labelText: 'كلمة المرور *',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  prefixIcon: Icon(Icons.lock, color: Colors.white70),
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
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _showAddUserForm = false);
                      _fieldControllers.values.forEach((controller) => controller.clear());
                      _selectedRole = 'user';
                    },
                    child: Text('إلغاء', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ],
          ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إدارة المستخدمين',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _showAddUserForm = !_showAddUserForm);
                  },
                  child: Text(_showAddUserForm ? 'إخفاء النموذج' : 'إضافة مستخدم'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            if (_showAddUserForm) _buildAddUserForm(),
            if (_showAddUserForm) SizedBox(height: 20),
            
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : _users.isEmpty
                      ? Center(
                          child: Text(
                            'لا يوجد مستخدمين مسجلين',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : Scrollbar(
                          controller: _listScrollController,
                          child: ListView.builder(
                            controller: _listScrollController,
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return Card(
                                elevation: 2,
                                color: Colors.grey[900],
                                margin: EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(
                                    user.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'كود: ${user.code} - الدور: ${user.role == 'admin' ? 'مدير' : 'مستخدم'}',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteUser(user),
                                    tooltip: 'حذف',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}