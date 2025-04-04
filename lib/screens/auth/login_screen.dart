import 'package:flutter/material.dart';
import 'package:alson_education/services/auth_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال اسم المستخدم وكلمة المرور', style: TextStyle(color: AppColors.errorColor))),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = await _authService.login(_usernameController.text, _passwordController.text);
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home', arguments: user.toMap());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بيانات غير صحيحة', style: TextStyle(color: AppColors.errorColor))),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alson Education', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/icon.png', width: 150),
            Text('مرحبًا بك في الألسن!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'اسم الطالب',
                prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'كود الطالب',
                prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.visibility, color: AppColors.primaryColor),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator(color: AppColors.primaryColor)
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('تسجيل الدخول', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: Size(200, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('سيتم إضافة الخاصية لاحقًا', style: TextStyle(color: AppColors.accentColor))),
                );
              },
              child: Text('هل نسيت كلمة المرور؟', style: TextStyle(color: AppColors.accentColor)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
