import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/providers/theme_provider.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:alson_education/constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('home', appState.language)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppStrings.get('confirm_logout', appState.language) ?? 'Confirm Logout'),
                    content: Text(AppStrings.get('are_you_sure', appState.language) ?? 'Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppStrings.get('cancel', appState.language) ?? 'Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          appState.logout();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: Text(AppStrings.get('logout', appState.language) ?? 'Logout'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'language') {
                appState.setLanguage(appState.language == 'ar' ? 'en' : 'ar');
              } else {
                Navigator.pushNamed(context, '/$value');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'profile', child: Text(AppStrings.get('profile', appState.language))),
              PopupMenuItem(value: 'content', child: Text(AppStrings.get('content', appState.language))),
              PopupMenuItem(value: 'chat', child: Text(AppStrings.get('chat', appState.language))),
              PopupMenuItem(value: 'results', child: Text(AppStrings.get('results', appState.language))),
              PopupMenuItem(value: 'help', child: Text(AppStrings.get('help', appState.language))),
              PopupMenuItem(value: 'language', child: Text(AppStrings.get('toggle_language', appState.language))),
              PopupMenuItem(value: 'logout', child: Text(AppStrings.get('logout', appState.language))),
              if (appState.isAdmin) PopupMenuItem(value: 'admin/users', child: const Text('Manage Users')),
              if (appState.isAdmin) PopupMenuItem(value: 'admin/upload', child: const Text('Upload Content')),
            ],
          ),
        ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
