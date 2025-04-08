import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/screens/onboarding_screen.dart';
import 'package:alson_education/screens/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => appState.currentUserCode == null ? const OnboardingScreen() : const HomeScreen(),
        ),
      );
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/img/icon.png', width: 150),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
