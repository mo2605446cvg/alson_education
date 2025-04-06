import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> validateLogin(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setLoading(true);

    final db = await DatabaseService.instance.database;
    final result = await db.rawQuery(
        "SELECT * FROM users WHERE username=? AND password=?",
        [_usernameController.text.trim(), _passwordController.text.trim()]);

    if (result.isNotEmpty) {
      final user = result.first;
      appState.login(user['username'] as String, user['code'] as String, user['role'] as String, user['department'] as String);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('بيانات غير صحيحة', style: TextStyle(color: Colors.red))));
    }

    appState.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Alson Education')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/icon.png', width: 150),
              Text('مرحبًا بك في الألسن!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: PRIMARY_COLOR)),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'اسم الطالب', prefixIcon: Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'كود الطالب', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), suffixIcon: Icon(Icons.visibility)),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: appState.isLoading ? null : () => validateLogin(context),
                child: Text('تسجيل الدخول'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                  foregroundColor: Colors.white,
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              TextButton(onPressed: () {}, child: Text('هل نسيت كلمة المرور؟', style: TextStyle(color: PRIMARY_COLOR))),
              if (appState.isLoading) CircularProgressIndicator(color: PRIMARY_COLOR),
            ],
          ),
        ),
      ),
    );
  }
}