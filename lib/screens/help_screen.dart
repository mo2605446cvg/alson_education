import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/strings.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('help', appState.language))),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(AppStrings.get('contact_us', appState.language)),
            Text('Email: m.nasrmm2002@gmail.com'),
            Text('Phone: 01023828155'),
          ],
        ),
      ),
    );
  }
}