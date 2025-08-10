
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_codeController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كود المستخدم وكلمة المرور', style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await loginUser(_codeController.text, _passwordController.text);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toJson()));
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تسجيل الدخول: بيانات غير صحيحة', style: TextStyle(fontFamily: 'Cairo'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تسجيل الدخول: $e', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'كود المستخدم', hintStyle: TextStyle(fontFamily: 'Cairo')),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور', hintStyle: TextStyle(fontFamily: 'Cairo')),
                obscureText: true,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo')),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
