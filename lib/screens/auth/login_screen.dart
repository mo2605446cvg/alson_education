import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:alson_education/services/auth_service.dart';
import 'package:alson_education/services/notification_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:alson_education/screens/models/user.dart';
import 'dart:math';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showOtp = false;
  String _otpCode = '';
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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
      setState(() {
        _otpCode = (1000 + Random().nextInt(9000)).toString(); // رمز OTP عشوائي
        _showOtp = true;
      });
      await NotificationService().showNotification('رمز OTP', 'رمز التحقق الخاص بك هو: $_otpCode');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بيانات غير صحيحة', style: TextStyle(color: AppColors.errorColor))),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp == _otpCode) {
      final user = await _authService.login(_usernameController.text, _passwordController.text);
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home', arguments: user.toMap());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رمز OTP غير صحيح', style: TextStyle(color: AppColors.errorColor))),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final user = User(
          code: googleUser.id,
          username: googleUser.displayName ?? 'Google User',
          department: 'غير محدد',
          role: 'user',
          password: '',
        );
        Navigator.pushReplacementNamed(context, '/home', arguments: user.toMap());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تسجيل الدخول بجوجل: $e', style: TextStyle(color: AppColors.errorColor))),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alson Education')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/icon.png', width: 150),
              Text('مرحبًا بك في الألسن!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              if (!_showOtp) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الطالب',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'كود الطالب',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    suffixIcon: Icon(Icons.visibility),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _login,
                            child: Text('تسجيل الدخول'),
                            style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _signInWithGoogle,
                            icon: Icon(Icons.login),
                            label: Text('تسجيل الدخول بجوجل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: Size(200, 50),
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {},
                  child: Text('هل نسيت كلمة المرور؟'),
                ),
              ] else ...[
                Text('أدخل رمز OTP المرسل إليك', style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 20),
                OtpTextField(
                  numberOfFields: 4,
                  borderColor: AppColors.primaryColor,
                  focusedBorderColor: AppColors.accentColor,
                  showFieldAsBox: true,
                  onCodeChanged: (String code) {},
                  onSubmit: _verifyOtp,
                ),
              ],
            ],
          ),
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
