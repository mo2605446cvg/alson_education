import 'package:flutter/material.dart';
import 'package:alson_education/database/database_helper.dart';
import 'package:alson_education/models/user.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;
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
    // في التطبيق الحقيقي، يجب استبدال 'admin123' بآيدي المستخدم الحالي
    final db = await DatabaseHelper.instance.database;
    final user = await db.query('users', where: 'code = ?', whereArgs: ['admin123']);
    
    if (user.isNotEmpty) {
      setState(() {
        _currentUser = User.fromMap(user.first);
        _usernameController.text = _currentUser.username;
        _departmentController.text = _currentUser.department;
        _passwordController.text = _currentUser.password;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final db = await DatabaseHelper.instance.database;
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
        SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              child: Text('حفظ', style: TextStyle(color: Colors.white)),
              onPressed: _updateProfile,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/profile_placeholder.png'),
                        child: _isEditing
                            ? IconButton(
                                icon: Icon(Icons.camera_alt, size: 30),
                                onPressed: () => _changeProfileImage(),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildProfileField(
                      label: 'الكود الجامعي',
                      value: _currentUser.code,
                      isEditable: false,
                    ),
                    SizedBox(height: 20),
                    _buildEditableField(
                      controller: _usernameController,
                      label: 'اسم المستخدم',
                      icon: Icons.person,
                      isEditing: _isEditing,
                    ),
                    SizedBox(height: 20),
                    _buildEditableField(
                      controller: _departmentController,
                      label: 'القسم',
                      icon: Icons.school,
                      isEditing: _isEditing,
                    ),
                    SizedBox(height: 20),
                    _buildEditableField(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      icon: Icons.lock,
                      isEditing: _isEditing,
                      isPassword: true,
                    ),
                    if (_isEditing) SizedBox(height: 30),
                    if (_isEditing)
                      Center(
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          child: Text('حفظ التغييرات'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 50),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileField({required String label, required String value, bool isEditable = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
              if (isEditable) Icon(Icons.edit, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isEditing,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
        SizedBox(height: 5),
        isEditing
            ? TextFormField(
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(icon),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
              )
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isPassword ? '••••••••' : controller.text,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

 Future<void> _changeProfileImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  
  if (pickedFile != null) {
    // يمكنك هنا حفظ الصورة أو رفعها إلى السيرفر
    setState(() {
      // تحديث حالة الصورة مؤقتاً
    });
  }
}
}