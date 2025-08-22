import 'package:flutter/material.dart';
import 'package:alson_education/models/user.dart';

class NavigationRailWidget extends StatelessWidget {
  final User user;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Function() onLogout;

  NavigationRailWidget({
    required this.user,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).primaryColorDark,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemSelected,
        labelType: NavigationRailLabelType.all,
        backgroundColor: Theme.of(context).primaryColorDark,
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: Colors.white70),
        selectedLabelTextStyle: TextStyle(color: Colors.white),
        unselectedLabelTextStyle: TextStyle(color: Colors.white70),
        destinations: [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('الرئيسية'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: Text('المحتوى'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: Text('الشات'),
          ),
          if (user.role == 'admin')
            NavigationRailDestination(
              icon: Icon(Icons.upload_outlined),
              selectedIcon: Icon(Icons.upload),
              label: Text('رفع'),
            ),
          if (user.role == 'admin')
            NavigationRailDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: Text('المستخدمين'),
            ),
          NavigationRailDestination(
            icon: Icon(Icons.logout_outlined),
            selectedIcon: Icon(Icons.logout),
            label: Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}