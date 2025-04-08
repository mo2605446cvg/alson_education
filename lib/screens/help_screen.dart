import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/strings.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('help', appState.language)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppStrings.get('contact_us', appState.language),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text('Email: m.nasrmm2002@gmail.com', textAlign: TextAlign.center),
                const Text('Phone: 01023828155', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
