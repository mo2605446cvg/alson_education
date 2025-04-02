import 'package:flutter/material.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/database/database_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    final users = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [_usernameController.text, _passwordController.text],
    );

    if (users.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بيانات الدخول غير صحيحة')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 150),
                SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المستخدم',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'يجب إدخال اسم المستخدم' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'يجب إدخال كلمة المرور' : null,
                ),
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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