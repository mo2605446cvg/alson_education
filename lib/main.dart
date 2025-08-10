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
import 'dart:html' as html;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // تهيئة Firebase مع معالجة الأخطاء
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // طلب إذن الإشعارات للويب
    if (html.window.navigator.serviceWorker != null) {
      try {
        html.window.navigator.serviceWorker.register('/firebase-messaging-sw.js').then((registration) {
          print('Service Worker registered');
          FirebaseMessaging.instance.getToken().then((token) {
            print('FCM Token: $token');
          });
        }).catchError((error) {
          print('Service Worker registration failed: $error');
        });
        await FirebaseMessaging.instance.requestPermission();
      } catch (e) {
        print('Error initializing Firebase Messaging for web: $e');
      }
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
        ),
        initialRoute: initialUser == null ? '/login' : '/home',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/content': (context) => const ContentList(),
          '/upload': (context) => const ContentUploadScreen(),
          '/users': (context) => const UserManagementScreen(),
          '/chat': (context) => const ChatScreen(),
        },
      ),
    );
  }
}
