import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/screens/auth/login_screen.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/screens/user/profile_screen.dart';
import 'package:alson_education/screens/content_screen.dart';
import 'package:alson_education/screens/chat_screen.dart';
import 'package:alson_education/screens/results_screen.dart';
import 'package:alson_education/screens/help_screen.dart';
import 'package:alson_education/screens/admin/admin_dashboard.dart';
import 'package:alson_education/screens/admin/user_management.dart';
import 'package:alson_education/screens/admin/content_management.dart';
import 'package:alson_education/screens/user/user_dashboard.dart';
import 'package:alson_education/utils/theme.dart';
import 'package:alson_education/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const AlsonEducation(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get theme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class AlsonEducation extends StatelessWidget {
  const AlsonEducation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Alson Education',
          theme: themeProvider.theme,
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
      },
    );
  }
}
