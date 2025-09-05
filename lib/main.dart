import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/screens/guest_screen.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/services/notification_service.dart';
import 'package:alson_education/models/user.dart' as app_user;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: 'https://hsgqgjkrbmkaxwhnktfv.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhzZ3FnamtyYm1rYXh3aG5rdGZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyMTM1NDQsImV4cCI6MjA3MTc4OTU0NH0.WO3CQv-iHaxAin8pbS9h0CmDzfFC4Kb4sTaaYbBDM_Q',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize Supabase: $e');
  }

  runApp(AlalsunApp());
}

class AlalsunApp extends StatefulWidget {
  @override
  _AlalsunAppState createState() => _AlalsunAppState();
}

class _AlalsunAppState extends State<AlalsunApp> {
  final ApiService apiService = ApiService();
  final NotificationService notificationService = NotificationService();
  app_user.AppUser? currentUser;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final isConnected = await apiService.checkSupabaseConnection();
      if (!isConnected) {
        setState(() {
          _connectionError = 'فشل في الاتصال بالسيرفر. يرجى التحقق من الإنترنت';
        });
      } else {
        setState(() {
          _connectionError = null;
        });
      }
    } catch (e) {
      setState(() {
        _connectionError = 'خطأ في الاتصال: $e';
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      setState(() {
        currentUser = app_user.AppUser.fromJson(json.decode(userData));
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notificationService.clearNotifications();
    setState(() {
      currentUser = null;
    });
  }

  void _login(app_user.AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
    setState(() {
      currentUser = user;
      _connectionError = null; // مسح رسالة الخطأ عند تسجيل الدخول الناجح
    });
  }

  void _loginAsGuest() async {
    final guestUser = app_user.AppUser(
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
          primary: Color(0xFF2196F3),
          primaryContainer: Color(0xFF64B5F6),
          secondary: Color(0xFF4FC3F7),
          background: Color(0xFFE3F2FD),
          surface: Color(0xFFFFFFFF),
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Color(0xFFE3F2FD),
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: _buildHomeWithConnectionCheck(),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildHomeWithConnectionCheck() {
    if (_connectionError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 64, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'خطأ في الاتصال',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                _connectionError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkConnection,
                child: Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return currentUser != null
        ? (currentUser!.role == 'admin'
            ? HomeScreen(
                user: currentUser!, 
                apiService: apiService, 
                onLogout: _logout,
                notificationService: notificationService,
              )
            : (currentUser!.role == 'guest'
                ? GuestScreen(user: currentUser!, onLogout: _logout)
                : HomeScreen(
                    user: currentUser!, 
                    apiService: apiService, 
                    onLogout: _logout,
                    notificationService: notificationService,
                  )))
        : LoginScreen(
            apiService: apiService, 
            onLogin: _login, 
            onLoginAsGuest: _loginAsGuest,
          );
  }
}