import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/screens/splash_screen.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/screens/profile_screen.dart';
import 'package:alson_education/screens/admin_users_screen.dart';
import 'package:alson_education/screens/upload_content_screen.dart';
import 'package:alson_education/screens/content_screen.dart';
import 'package:alson_education/screens/chat_screen.dart';
import 'package:alson_education/screens/results_query_screen.dart';
import 'package:alson_education/screens/view_result_screen.dart';
import 'package:alson_education/screens/help_screen.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/providers/theme_provider.dart';
import 'package:alson_education/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database; // تهيئة قاعدة البيانات
  runApp(AlsonEducation());
}

class AlsonEducation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Alson Education',
            theme: themeProvider.themeData,
            home: SplashScreen(),
            routes: {
              '/home': (context) => HomeScreen(),
              '/profile': (context) => ProfileScreen(),
              '/admin/users': (context) => AdminUsersScreen(),
              '/admin/upload': (context) => UploadContentScreen(),
              '/content': (context) => ContentScreen(),
              '/chat': (context) => ChatScreen(),
              '/results': (context) => ResultsQueryScreen(),
              '/view_results': (context) => ViewResultsScreen(),
              '/help': (context) => HelpScreen(),
            },
          );
        },
      ),
    );
  }
}
