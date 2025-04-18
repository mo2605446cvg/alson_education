import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/screens/splash_screen.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/screens/profile_screen.dart';
import 'package:alson_education/screens/admin_users_screen.dart';
import 'package:alson_education/screens/admin_dashboard_screen.dart';
import 'package:alson_education/screens/upload_content_screen.dart';
import 'package:alson_education/screens/content_screen.dart';
import 'package:alson_education/screens/chat_screen.dart';
import 'package:alson_education/screens/results_query_screen.dart';
import 'package:alson_education/screens/view_results_screen.dart';
import 'package:alson_education/screens/help_screen.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/screens/register_screen.dart';
import 'package:alson_education/screens/onboarding_screen.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/providers/theme_provider.dart';

void main() {
  runApp(const AlsonEducation());
}

class AlsonEducation extends StatelessWidget {
  const AlsonEducation({super.key});

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
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/admin/users': (context) => const AdminUsersScreen(),
              '/admin/dashboard': (context) => const AdminDashboardScreen(),
              '/admin/upload': (context) => const UploadContentScreen(),
              '/content': (context) => const ContentScreen(),
              '/chat': (context) => const ChatScreen(),
              '/results': (context) => const ResultsQueryScreen(),
              '/view_results': (context) => ViewResultsScreen(),
              '/help': (context) => const HelpScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/error': (context) => const ErrorScreen(errorMessage: 'An error occurred'),
            },
            initialRoute: '/splash',
          );
        },
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String errorMessage;

  const ErrorScreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Error: $errorMessage', style: TextStyle(color: Colors.red)),
      ),
    );
  }
}
