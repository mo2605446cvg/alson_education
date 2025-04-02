import 'package:flutter/material.dart';
import 'package:alson_education/screens/alson_education_login_screen.dart';
import 'package:alson_education/screens/alson_education_home_screen.dart';
import 'package:alson_education/screens/alson_education_profile_screen.dart';
import 'package:alson_education/screens/alson_education_user_management_screen.dart';
import 'package:alson_education/screens/alson_education_content_screen.dart';
import 'package:alson_education/screens/alson_education_upload_content_screen.dart';
import 'package:alson_education/screens/alson_education_chat_screen.dart';
import 'package:alson_education/screens/alson_education_results_screen.dart';
import 'package:alson_education/screens/alson_education_help_screen.dart';
import 'package:alson_education/models/alson_education_user.dart';
import 'package:alson_education/database/alson_education_database.dart';
import 'package:alson_education/theme/alson_education_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlsonEducationDatabase.initDB();
  runApp(const AlsonEducationApp());
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AlsonEducationLoginScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          assert(args is AlsonEducationUser, 'يجب تمرير AlsonEducationUser كـ arguments');
          return AlsonEducationHomeScreen(currentUser: args as AlsonEducationUser);
        },
        '/profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          assert(args is AlsonEducationUser, 'يجب تمرير AlsonEducationUser كـ arguments');
          return AlsonEducationProfileScreen(userCode: (args as AlsonEducationUser).code);
        },
        '/user-management': (context) => const AlsonEducationUserManagementScreen(),
        '/content': (context) => const AlsonEducationContentScreen(),
        '/upload-content': (context) => const AlsonEducationUploadContentScreen(),
        '/chat': (context) => const AlsonEducationChatScreen(),
        '/results': (context) => const AlsonEducationResultsScreen(),
        '/help': (context) => const AlsonEducationHelpScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('الصفحة غير موجودة')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('404 - الصفحة غير موجودة'),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('العودة للصفحة الرئيسية'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
