import 'package:flutter/material.dart';
import 'package:alson_education/constants/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isAdmin;

  CustomAppBar(this.title, {this.isAdmin = false});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
      backgroundColor: PRIMARY_COLOR,
      leading: Icon(Icons.school, color: Colors.white, size: 30),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (String result) {
            // يمكن إضافة المنطق هنا
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(value: 'profile', child: Row(children: [Icon(Icons.person), Text('الملف الشخصي')])),
            PopupMenuItem<String>(value: 'results', child: Row(children: [Icon(Icons.grade), Text('النتيجة')])),
            PopupMenuItem<String>(value: 'content', child: Row(children: [Icon(Icons.folder), Text('المحتوى')])),
            PopupMenuItem<String>(value: 'chat', child: Row(children: [Icon(Icons.chat), Text('الشات')])),
            PopupMenuItem<String>(value: 'help', child: Row(children: [Icon(Icons.help), Text('المساعدة')])),
            PopupMenuItem<String>(value: 'logout', child: Row(children: [Icon(Icons.logout), Text('تسجيل الخروج')])),
            if (isAdmin)
              PopupMenuItem<String>(value: 'admin/users', child: Row(children: [Icon(Icons.edit), Text('إدارة المستخدمين')])),
            if (isAdmin)
              PopupMenuItem<String>(value: 'admin/upload', child: Row(children: [Icon(Icons.upload), Text('رفع المحتوى')])),
          ],
        ),
      ],
    );
  }
}