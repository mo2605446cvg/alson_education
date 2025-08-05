
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _validateLogin() async {
    if (_codeController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كود المستخدم وكلمة المرور')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await loginUser(_codeController.text, _passwordController.text);
      Provider.of<UserProvider>(context, listen: false).login(user);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon.png', width: 128, height: 128),
                const Text(
                  'مرحبًا بك في الألسن!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: primaryColor),
                    hintText: 'كود المستخدم (مثال: ADMIN001)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: primaryColor),
                    hintText: 'كلمة المرور',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _validateLogin,
                  child: Text(
                    _isLoading ? 'جارٍ التحميل...' : 'تسجيل الدخول',
                    style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : () {},
                  child: const Text(
                    'هل نسيت كلمة المرور؟',
                    style: TextStyle(color: primaryColor, fontFamily: 'Cairo'),
                  ),
                ),
              ],
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
