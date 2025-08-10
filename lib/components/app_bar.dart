
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alson_education/providers/user_provider.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isAdmin;

  const AppBarWidget({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Alson Education', style: TextStyle(fontFamily: 'Cairo')),
      actions: [
        if (isAdmin) ...[
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => Navigator.pushNamed(context, '/upload'),
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Navigator.pushNamed(context, '/users'),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () => Navigator.pushNamed(context, '/chat'),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('user');
            Provider.of<UserProvider>(context, listen: false).setUser(null);
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}