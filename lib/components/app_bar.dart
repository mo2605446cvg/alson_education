import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/providers/user_provider.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isAdmin;

  const AppBarWidget({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('أكاديمية السن', style: TextStyle(fontFamily: 'Cairo')),
      backgroundColor: primaryColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: () => Navigator.pushNamed(context, '/content'),
          tooltip: 'المحتوى',
        ),
        if (isAdmin) ...[
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => Navigator.pushNamed(context, '/upload'),
            tooltip: 'رفع محتوى',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Navigator.pushNamed(context, '/users'),
            tooltip: 'إدارة المستخدمين',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () => Navigator.pushNamed(context, '/chat'),
          tooltip: 'الشات',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Provider.of<UserProvider>(context, listen: false).clearUser();
            Navigator.pushReplacementNamed(context, '/login');
          },
          tooltip: 'تسجيل الخروج',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
