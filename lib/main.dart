import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart'; // تحديث المسار
import 'screens/home_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/content_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/results_screen.dart';
import 'screens/help_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/user_management.dart';
import 'screens/admin/content_management.dart';
import 'screens/user/user_dashboard.dart';
import 'utils/colors.dart';

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
        '/user/dashboard': (context) => const UserDashboard(),
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
