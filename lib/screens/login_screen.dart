import 'dart:async'; // أضف هذا السطر
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart' as app_user;

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
  bool _checkingConnection = false;

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
    _checkServerConnection();
  }

  Future<void> _checkServerConnection() async {
    setState(() => _checkingConnection = true);
    try {
      final isConnected = await widget.apiService.checkSupabaseConnection();
      if (!isConnected) {
        setState(() {
          _errorMessage = 'فشل في الاتصال بالسيرفر. يرجى التحقق من الإنترنت';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في الاتصال: $e';
      });
    } finally {
      setState(() => _checkingConnection = false);
    }
  }

  Future<void> _checkLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      final user = app_user.AppUser.fromJson(json.decode(userData));
      widget.onLogin(user);
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 10));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
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

    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في الاتصال بالإنترنت. يرجى التحقق من اتصالك';
      });
      return;
    }

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
      
      if (e.toString().contains('الاتصال') || 
          e.toString().contains('SocketException') ||
          e.toString().contains('فشل في الاتصال') ||
          e.toString().contains('TimeoutException')) {
        errorMessage = 'فشل في الاتصال بالسيرفر. يرجى التحقق من الإنترنت';
      } else if (e.toString().contains('كود المستخدم') || 
                 e.toString().contains('كلمة المرور') ||
                 e.toString().contains('بيانات الدخول')) {
        errorMessage = 'كود المستخدم أو كلمة المرور غير صحيحة';
      } else if (e.toString().contains('الخادم') || 
                 e.toString().contains('قاعدة البيانات')) {
        errorMessage = 'خطأ في الخادم. يرجى المحاولة لاحقاً';
      } else {
        errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
      }
      
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  void _clearError() {
    setState(() {
      _errorMessage = '';
    });
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
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
              Color(0xFF90CAF9),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.school,
                      size: 60,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  Text(
                    "أكاديمية الألسن",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black45,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 5),
                  
                  Text(
                    "منصة التعلم الإلكتروني المتكاملة",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  
                  SizedBox(height: 40),

                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          if (_errorMessage.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(color: Colors.red, fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 16, color: Colors.red),
                                    onPressed: _clearError,
                                  ),
                                ],
                              ),
                            ),
                          
                          if (_errorMessage.isNotEmpty) SizedBox(height: 20),

                          TextField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              labelText: "كود المستخدم",
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              prefixIcon: Icon(Icons.person, color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.text,
                            style: TextStyle(fontSize: 16),
                          ),
                          
                          SizedBox(height: 20),

                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: "كلمة المرور",
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              prefixIcon: Icon(Icons.lock, color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 16),
                          ),
                          
                          SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login, size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          "تسجيل الدخول",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          
                          SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : widget.onLoginAsGuest,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xFF1976D2),
                                side: BorderSide(color: Color(0xFF1976D2)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_outline, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "تسجيل الدخول كضيف",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 15),

                          TextButton(
                            onPressed: _isLoading ? null : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("يرجى التواصل مع المدير لاستعادة كلمة المرور"),
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Color(0xFF1976D2),
                                ),
                              );
                            },
                            child: Text(
                              "نسيت كلمة المرور؟",
                              style: TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 14,
                              ),
                            ),
                          ),

                          if (_checkingConnection)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "جاري التحقق من الاتصال...",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  Text(
                    "© 2024 أكاديمية الألسن. جميع الحقوق محفوظة",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

