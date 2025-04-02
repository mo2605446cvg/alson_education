import 'package:flutter/material.dart';
import 'package:alson_education/screens/alson_education_login_screen.dart';
import 'package:alson_education/theme/alson_education_theme.dart';
import 'package:alson_education/models/alson_education_user.dart';
import 'package:alson_education/database/alson_education_database.dart';
import 'package:alson_education/screens/alson_education_home_screen.dart';
import 'package:alson_education/screens/alson_education_profile_screen.dart';
import 'package:alson_education/screens/alson_education_user_management_screen.dart';
import 'package:alson_education/screens/alson_education_content_screen.dart';
import 'package:alson_education/screens/alson_education_upload_content_screen.dart';
import 'package:alson_education/screens/alson_education_chat_screen.dart';
import 'package:alson_education/screens/alson_education_results_screen.dart';
import 'package:alson_education/screens/alson_education_help_screen.dart';
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
