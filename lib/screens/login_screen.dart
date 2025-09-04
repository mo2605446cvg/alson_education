import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final ApiService apiService;
  final Function(app_user.AppUser) onLogin;
  final Function() onLoginAsGuest;

  LoginScreen({required this.apiService, required this.onLogin, required this.onLoginAsGuest});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      final user = app_user.AppUser.fromJson(json.decode(userData));
      widget.onLogin(user);
    }
  }

  Future<void> _login() async {
    if (_codeController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال جميع الحقول';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await widget.apiService.login(
        _codeController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (user != null) {
        widget.onLogin(user);
      }
    } catch (e) {
      String errorMessage = 'فشل في تسجيل الدخول';
      
      if (e.toString().contains('كود المستخدم غير صحيح')) {
        errorMessage = 'كود المستخدم غير صحيح';
      } else if (e.toString().contains('كلمة المرور غير صحيحة')) {
        errorMessage = 'كلمة المرور غير صحيحة';
      } else if (e.toString().contains('الاتصال')) {
        errorMessage = 'فشل في الاتصال بالسيرفر. يرجى التحقق من الإنترنت';
      } else if (e.toString().contains('قاعدة البيانات')) {
        errorMessage = 'خطأ في الخادم. يرجى المحاولة لاحقاً';
      }
      
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              margin: EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(30),
                width: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://via.placeholder.com/150?text=Alson+Logo",
                      width: 120,
                      height: 120,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "أكاديمية الألسن",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 30),

                    // رسالة الخطأ
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_errorMessage.isNotEmpty) SizedBox(height: 20),

                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: "كود المستخدم",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                      ),
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "كلمة المرور",
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.login),
                                SizedBox(width: 10),
                                Text("تسجيل الدخول"),
                              ],
                            ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: widget.onLoginAsGuest,
                      child: Text("تسجيل الدخول كضيف"),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("يرجى التواصل مع المدير لاستعادة كلمة المرور")),
                        );
                      },
                      child: Text("نسيت كلمة المرور؟"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}