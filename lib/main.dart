import 'package:flutter/material.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlsonEducationDatabase.initDB();
  runApp(AlsonEducationApp());
}

class AlsonEducationApp extends StatelessWidget {
  const AlsonEducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alson Education',
      debugShowCheckedModeBanner: false,
      theme: AlsonEducationTheme.lightTheme,
      darkTheme: AlsonEducationTheme.darkTheme,
      home: AlsonEducationLoginScreen(),
      routes: {
        '/home': (context) => AlsonEducationHomeScreen(),
        '/profile': (context) => AlsonEducationProfileScreen(),
        '/user-management': (context) => AlsonEducationUserManagementScreen(),
        '/content': (context) => AlsonEducationContentScreen(),
        '/upload-content': (context) => AlsonEducationUploadContentScreen(),
        '/chat': (context) => AlsonEducationChatScreen(),
        '/results': (context) => AlsonEducationResultsScreen(),
        '/help': (context) => AlsonEducationHelpScreen(),
      },
    );
  }
}