import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/screens/content_list.dart';
import 'package:alson_education/screens/content_upload.dart';
import 'package:alson_education/screens/user_management.dart';
import 'package:alson_education/screens/chat.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alson_education/models/user.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');
  User? initialUser;
  if (userJson != null) {
    initialUser = User.fromJson(jsonDecode(userJson));
  }
  runApp(MyApp(initialUser: initialUser));
}

class MyApp extends StatelessWidget {
  final User? initialUser;

  const MyApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider()..setUser(initialUser),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Cairo',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontFamily: 'Cairo'),
            headlineSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            bodySmall: TextStyle(fontFamily: 'Cairo'),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[700],
              textStyle: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        initialRoute: initialUser == null ? '/login' : (initialUser!.role == 'admin' ? '/users' : '/content'),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/content': (context) => const ContentList(),
          '/upload': (context) => const ContentUpload(),
          '/users': (context) => const UserManagement(),
          '/chat': (context) => const ChatScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}