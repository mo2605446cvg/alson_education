import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        primaryColor: Color(0xFF128C7E),
        primaryColorDark: Color(0xFF075E54),
        accentColor: Color(0xFF25D366),
        scaffoldBackgroundColor: Color(0xFFF0F2F5),
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          headline4: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo-Bold',
          ),
          bodyText1: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF128C7E),
        primaryColorDark: Color(0xFF075E54),
        accentColor: Color(0xFF25D366),
        scaffoldBackgroundColor: Color(0xFF121B22),
        cardColor: Color(0xFF1F2C34),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar', 'AE'),
      ],
      home: LoginScreen(apiService: apiService),
    );
  }
}