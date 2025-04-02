import 'package:flutter/material.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initDB();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alson Education',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/user-management': (context) => UserManagementScreen(),
        '/content': (context) => ContentScreen(),
        '/upload-content': (context) => UploadContentScreen(),
        '/chat': (context) => ChatScreen(),
        '/results': (context) => ResultsScreen(),
        '/help': (context) => HelpScreen(),
      },
    );
  }
}