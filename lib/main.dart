import 'package:flutter/material.dart';
import 'alson_education/screens/auth/login_screen.dart';
import 'alson_education/screens/home_screen.dart';
import 'alson_education/screens/profile_screen.dart';
import 'alson_education/screens/content_screen.dart';
import 'alson_education/screens/chat_screen.dart';
import 'alson_education/screens/results_screen.dart';
import 'alson_education/screens/help_screen.dart';
import 'alson_education/screens/admin/admin_dashboard.dart';
import 'alson_education/screens/admin/user_management.dart';
import 'alson_education/screens/admin/content_management.dart';
import 'alson_education/utils/colors.dart';

void main() {
  runApp(const AlsonEducation());
}

class AlsonEducation extends StatelessWidget {
  const AlsonEducation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alson Education',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: AppColors.secondaryColor,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/content': (context) => const ContentScreen(),
        '/chat': (context) => const ChatScreen(),
        '/results': (context) => const ResultsScreen(),
        '/show_results': (context) => const ShowResultsScreen(),
        '/help': (context) => const HelpScreen(),
        '/admin/dashboard': (context) => const AdminDashboard(),
        '/admin/users': (context) => const UserManagementScreen(),
        '/admin/content': (context) => const ContentManagementScreen(),
      },
    );
  }
}
