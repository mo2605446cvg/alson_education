import 'package:flutter/material.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isAdmin;

  CustomAppBar(this.title, {this.isAdmin = false});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      ),
      backgroundColor: PRIMARY_COLOR,
      leading: Icon(Icons.school, color: Colors.white, size: 30),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (String result) {
            if (result == 'logout') {
              appState.logout();
              Navigator.pushReplacementNamed(context, '/onboarding');
            } else {
              Navigator.pushNamed(context, '/$result');
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(children: [Icon(Icons.person), Text(AppStrings.get('profile', appState.language))]),
            ),
            PopupMenuItem<String>(
              value: 'results',
              child: Row(children: [Icon(Icons.grade), Text(AppStrings.get('results', appState.language))]),
            ),
            PopupMenuItem<String>(
              value: 'content',
              child: Row(children: [Icon(Icons.folder), Text(AppStrings.get('content', appState.language))]),
            ),
            PopupMenuItem<String>(
              value: 'chat',
              child: Row(children: [Icon(Icons.chat), Text(AppStrings.get('chat', appState.language))]),
            ),
            PopupMenuItem<String>(
              value: 'help',
              child: Row(children: [Icon(Icons.help), Text(AppStrings.get('help', appState.language))]),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(children: [Icon(Icons.logout), Text(AppStrings.get('logout', appState.language))]),
            ),
            if (isAdmin)
              PopupMenuItem<String>(
                value: 'admin/dashboard',
                child: Row(children: [Icon(Icons.dashboard), Text(AppStrings.get('admin_dashboard', appState.language))]),
              ),
            if (isAdmin)
              PopupMenuItem<String>(
                value: 'admin/users',
                child: Row(children: [Icon(Icons.edit), Text(AppStrings.get('admin_users', appState.language))]),
              ),
            if (isAdmin)
              PopupMenuItem<String>(
                value: 'admin/upload',
                child: Row(children: [Icon(Icons.upload), Text(AppStrings.get('upload_content', appState.language))]),
              ),
          ],
        ),
      ],
    );
  }
}
