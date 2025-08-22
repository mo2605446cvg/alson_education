import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/screens/home_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أكاديمية الألسن',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF128C7E),
          primaryContainer: Color(0xFF075E54),
          secondary: Color(0xFF25D366),
          background: Color(0xFFF0F2F5),
          surface: Color(0xFFFFFFFF),
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Color(0xFFF0F2F5),
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
            color: Color(0xFF128C7E),
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
            color: Color(0xFF075E54),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontFamily: 'Cairo',
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontFamily: 'Cairo',
            color: Colors.grey[700],
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF128C7E),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'Cairo-Bold',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF128C7E),
          primaryContainer: Color(0xFF075E54),
          secondary: Color(0xFF25D366),
          background: Color(0xFF121B22),
          surface: Color(0xFF1F2C34),
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFF121B22),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontFamily: 'Cairo',
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontFamily: 'Cairo',
            color: Colors.grey[300],
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Color(0xFF1F2C34),
        ),
      ),
      home: currentUser != null
          ? HomeScreen(user: currentUser!, apiService: apiService, onLogout: _logout)
          : LoginScreen(apiService: apiService, onLogin: _login),
    );
  }
}