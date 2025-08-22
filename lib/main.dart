import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/screens/guest_screen.dart'; // سيتم إنشاء هذا الملف
import 'package:alson_education/screens/admin_dashboard.dart'; // سيتم إنشاء هذا الملف
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart';

void main() {
  runApp(AlalsunApp());
}

class AlalsunApp extends StatefulWidget {
  @override
  _AlalsunAppState createState() => _AlalsunAppState();
}

class _AlalsunAppState extends State<AlalsunApp> {
  final ApiService apiService = ApiService();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      setState(() {
        currentUser = User.fromJson(json.decode(userData));
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    setState(() {
      currentUser = null;
    });
  }

  void _login(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
    setState(() {
      currentUser = user;
    });
  }

  void _loginAsGuest() async {
    final guestUser = User(
      code: 'guest',
      username: 'ضيف',
      department: '',
      division: '',
      role: 'guest',
    );
    _login(guestUser);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أكاديمية الألسن',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2196F3), // أزرق فاتح
          primaryContainer: Color(0xFF64B5F6), // أزرق أفتح
          secondary: Color(0xFF4FC3F7), // أزرق فاتح آخر
          background: Color(0xFFE3F2FD), // أزرق فاتح جداً
          surface: Color(0xFFFFFFFF),
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Color(0xFFE3F2FD),
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32, // حجم خط أكبر
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
            color: Color(0xFF2196F3),
          ),
          displayMedium: TextStyle(
            fontSize: 28, // حجم خط أكبر
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
            color: Color(0xFF1976D2),
          ),
          bodyLarge: TextStyle(
            fontSize: 18, // حجم خط أكبر
            fontFamily: 'Cairo',
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 16, // حجم خط أكبر
            fontFamily: 'Cairo',
            color: Colors.grey[700],
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'Cairo-Bold',
            fontSize: 24, // حجم خط أكبر في AppBar
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true, // جعل العنوان في المنتصف
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF2196F3),
          primaryContainer: Color(0xFF64B5F6),
          secondary: Color(0xFF4FC3F7),
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'Cairo-Bold',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontFamily: 'Cairo',
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontFamily: 'Cairo',
            color: Colors.grey[300],
          ),
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Color(0xFF1E1E1E),
        ),
      ),
      home: currentUser != null
          ? (currentUser!.role == 'admin'
              ? AdminDashboard(user: currentUser!, apiService: apiService, onLogout: _logout)
              : (currentUser!.role == 'guest'
                  ? GuestScreen(user: currentUser!, onLogout: _logout)
                  : HomeScreen(user: currentUser!, apiService: apiService, onLogout: _logout)))
          : LoginScreen(apiService: apiService, onLogin: _login, onLoginAsGuest: _loginAsGuest),
    );
  }
}