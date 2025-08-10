
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'dart:io' show Platform;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      try {
        await FirebaseMessaging.instance.requestPermission();
        final token = await FirebaseMessaging.instance.getToken();
        print('FCM Token: $token');
      } catch (e) {
        print('Error initializing Firebase Messaging: $e');
      }
    } else {
      print('Firebase Messaging skipped on desktop platforms');
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');
  User? initialUser;
  if (userJson != null) {
    try {
      initialUser = User.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error parsing user JSON: $e');
    }
  }

  runApp(MyApp(initialUser: initialUser));
}

class MyApp extends StatelessWidget {
  final User? initialUser;

  const MyApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..setUser(initialUser)),
      ],
      child: MaterialApp(
        title: 'Alson Education',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Cairo',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
            labelLarge: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: TextStyle(fontFamily: 'Cairo', color: Colors.black54),
            hintStyle: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
          ),
        ),
        initialRoute: initialUser == null ? '/login' : '/home',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/content': (context) => const ContentList(),
          '/upload': (context) => const ContentUpload(),
          '/users': (context) => const UserManagement(),
          '/chat': (context) => const ChatScreen(),
        },
      ),
    );
  }
}
