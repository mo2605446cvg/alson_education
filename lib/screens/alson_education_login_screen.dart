import 'package:flutter/material.dart';
import 'package:alson_education/database/alson_education_database.dart';
import 'package:alson_education/models/alson_education_user.dart';
import 'package:alson_education/screens/alson_education_home_screen.dart';

class AlsonEducationLoginScreen extends StatefulWidget {
  const AlsonEducationLoginScreen({super.key});

  @override
  _AlsonEducationLoginScreenState createState() => _AlsonEducationLoginScreenState();
}

class _AlsonEducationLoginScreenState extends State<AlsonEducationLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final db = await AlsonEducationDatabase.instance.database;
    final users = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [_usernameController.text, _passwordController.text],
    );

    if (users.isNotEmpty) {
      final user = AlsonEducationUser.fromMap(users.first);
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: user,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بيانات الدخول غير صحيحة')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 150),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'يجب إدخال اسم المستخدم' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'يجب إدخال كلمة المرور' : null,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
