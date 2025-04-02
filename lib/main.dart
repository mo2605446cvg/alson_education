import 'package:flutter/material.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/screens/profile_screen.dart';
import 'package:alson_education/screens/users_management_screen.dart';
import 'package:alson_education/screens/upload_content_screen.dart';
import 'package:alson_education/screens/content_screen.dart';
import 'package:alson_education/screens/chat_screen.dart';
import 'package:alson_education/screens/results_screen.dart';
import 'package:alson_education/screens/help_screen.dart';

void main() {
  runApp(const AlsonEducationApp());
}

class AlsonEducationApp extends StatelessWidget {
  const AlsonEducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alson Education',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[800],
        scaffoldBackgroundColor: Colors.grey[200],
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/users_management': (context) => const UsersManagementScreen(),
        '/upload_content': (context) => const UploadContentScreen(),
        '/content': (context) => const ContentScreen(),
        '/chat': (context) => const ChatScreen(),
        '/results': (context) => const ResultsScreen(),
        '/results_view': (context) => const ResultsViewScreen(),
        '/help': (context) => const HelpScreen(),
      },
    );
  }
}