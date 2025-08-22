import 'package:flutter/material.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/services/api_service.dart';

void main() {
  runApp(AlalsunApp());
}

class AlalsunApp extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أكاديمية الألسن',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF128C7E),
          secondary: Color(0xFF25D366),
          background: Color(0xFFF0F2F5),
        ),
        primaryColor: Color(0xFF128C7E),
        primaryColorDark: Color(0xFF075E54),
        scaffoldBackgroundColor: Color(0xFFF0F2F5),
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
          ),
          bodyLarge: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF128C7E),
          secondary: Color(0xFF25D366),
          background: Color(0xFF121B22),
        ),
        primaryColor: Color(0xFF128C7E),
        primaryColorDark: Color(0xFF075E54),
        scaffoldBackgroundColor: Color(0xFF121B22),
        cardColor: Color(0xFF1F2C34),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
          ),
          bodyLarge: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
        ),
      ),
      home: LoginScreen(apiService: apiService),
    );
  }
}