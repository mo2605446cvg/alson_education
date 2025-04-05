import 'package:flutter/material.dart';
import 'package:alson_education/utils/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isAdmin;
  final Map<String, dynamic>? user;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isAdmin = false,
    this.user,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.primaryColor,
      leading: Icon(Icons.school, color: Colors.white, size: 30),
      actions: actions ?? [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String result) {
            switch (result) {
              case 'profile':
                Navigator.pushNamed(context, '/profile', arguments: user);
                break;
              case 'results':
                Navigator.pushNamed(context, '/results');
                break;
              case 'content':
                Navigator.pushNamed(context, '/content');
                break;
              case 'chat':
                Navigator.pushNamed(context, '/chat', arguments: user);
                break;
              case 'help':
                Navigator.pushNamed(context, '/help');
                break;
              case 'logout':
                Navigator.pushReplacementNamed(context, '/');
                break;
              case 'manageUsers':
                Navigator.pushNamed(context, '/admin/users');
                break;
              case 'uploadContent':
                Navigator.pushNamed(context, '/admin/content');
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            if (isAdmin) const PopupMenuItem<String>(value: 'manageUsers', child: Text('إدارة المستخدمين')),
            if (isAdmin) const PopupMenuItem<String>(value: 'uploadContent', child: Text('رفع المحتوى')),
            const PopupMenuItem<String>(value: 'profile', child: Text('الملف الشخصي')),
            const PopupMenuItem<String>(value: 'results', child: Text('النتيجة')),
            const PopupMenuItem<String>(value: 'content', child: Text('المحتوى')),
            const PopupMenuItem<String>(value: 'chat', child: Text('الشات')),
            const PopupMenuItem<String>(value: 'help', child: Text('المساعدة')),
            const PopupMenuItem<String>(value: 'logout', child: Text('تسجيل الخروج')),
          ],
        ),
      ],
    );
  }
}
