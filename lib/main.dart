import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:alson_education/screens/profile_screen.dart';
import 'package:alson_education/screens/admin_users_screen.dart';
import 'package:alson_education/screens/upload_content_screen.dart';
import 'package:alson_education/screens/content_screen.dart';
import 'package:alson_education/screens/chat_screen.dart';
import 'package:alson_education/screens/results_query_screen.dart';
import 'package:alson_education/screens/view_results_screen.dar';
import 'package:alson_education/screens/help_screen.dart';
import 'package:alson_education/widgets/app_bar_widget.dart';
import 'package:alson_education/widgets/custom_button.dart';
import 'package:alson_education/widgets/custom_card.dart';

void main() {
  runApp(AlsonEducation());
}

class AlsonEducation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Alson Education',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        home: LoginScreen(),
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
      ),
    );
  }
}