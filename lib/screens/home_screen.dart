import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/providers/theme_provider.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:alson_education/widgets/app_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        AppStrings.get('home', appState.language),
        isAdmin: appState.isAdmin,
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
                  '${AppStrings.get('hello', appState.language)} ${appState.currentUserEmail}',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (!appState.isAdmin)
                  Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(AppStrings.get('schedule', appState.language)),
                          Image.asset('assets/img/po.jpg', width: 340, fit: BoxFit.cover),
                        ],
                      ),
                    ),
                  ),
                if (appState.isAdmin)
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/admin/dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppStrings.get('admin_dashboard', appState.language)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
