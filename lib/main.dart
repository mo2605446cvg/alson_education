import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/screens/content_list.dart';
import 'package:alson_education/screens/content_upload.dart';
import 'package:alson_education/screens/user_management.dart';
import 'package:alson_education/screens/chat.dart';
import 'package:alson_education/screens/results.dart';
import 'package:alson_education/utils/api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Cairo',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/content': (context) => const ContentList(),
          '/upload': (context) => const ContentUpload(),
          '/users': (context) => const UserManagement(),
          '/chat': (context) => const ChatScreen(),
          '/results': (context) => const ResultsScreen(),
        },
      ),
    );
  }
}