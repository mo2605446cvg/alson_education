import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final ApiService apiService;

  LoginScreen({required this.apiService});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      final user = User.fromJson(json.decode(userData));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(user: user, apiService: widget.apiService),
        ),
      );
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await widget.apiService.login(
        _codeController.text,
        _passwordController.text,
      );
      
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(user: user, apiService: widget.apiService),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
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
              Theme.of(context).primaryColorDark,
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
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 30),
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
                          icon: Icon(Icons.visibility),
                          onPressed: () {},
                        ),
                      ),
                      obscureText: true,
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
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {},
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