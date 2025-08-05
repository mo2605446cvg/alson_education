
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/colors.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isAdmin;

  const AppBarWidget({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      title: const Text(
        'الألسن أكاديمي',
        style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.home, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, '/home'),
      ),
      actions: [
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/user_management'),
          ),
        IconButton(
          icon: const Icon(Icons.upload, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/content_upload'),
        ),
        IconButton(
          icon: const Icon(Icons.help, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/help'),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            Provider.of<UserProvider>(context, listen: false).logout();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}