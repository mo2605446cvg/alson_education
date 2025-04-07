import 'package:flutter/material.dart';
import 'package:alson_education/screens/login_screen.dart';
import 'package:alson_education/constants/strings.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.get('welcome', appState.language),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Text(
              AppStrings.get('intro', appState.language),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
              child: Text(AppStrings.get('start', appState.language)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}