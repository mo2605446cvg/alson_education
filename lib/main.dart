
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/screens/user_management.dart';
import 'package:alson_education/screens/content_upload.dart';
import 'package:alson_education/screens/content_list.dart';
import 'package:alson_education/screens/chat.dart';
import 'package:alson_education/screens/profile.dart';
import 'package:alson_education/screens/results.dart';
import 'package:alson_education/screens/help.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';

void main() {
  initializeNotifications();
  runApp(const AlsonAcademyApp());
}

class AlsonAcademyApp extends StatelessWidget {
  const AlsonAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'الألسن أكاديمي',
        theme: ThemeData(
          primaryColor: primaryColor,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontFamily: 'Cairo', color: textColor),
            headlineSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          fontFamily: 'Cairo',
        ),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/user_management': (context) => const UserManagement(),
          '/content_upload': (context) => const ContentUpload(),
          '/content': (context) => const ContentList(),
          '/chat': (context) => const Chat(),
          '/profile': (context) => const Profile(),
          '/results': (context) => const Results(),
          '/help': (context) => const Help(),
        },
      ),
    );
  }
}