import 'package:flutter/material.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/screens/content_screen.dart';
import 'package:alson_education/screens/chat_screen.dart';
import 'package:alson_education/screens/upload_screen.dart';
import 'package:alson_education/screens/users_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final ApiService apiService;
  final Function() onLogout;

  HomeScreen({required this.user, required this.apiService, required this.onLogout});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    HomeContentScreen(),
    ContentScreen(),
    ChatScreen(),
    UploadScreen(),
    UsersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _screens[0];
      case 1:
        return ContentScreen(apiService: widget.apiService, user: widget.user);
      case 2:
        return ChatScreen(apiService: widget.apiService, user: widget.user);
      case 3:
        if (widget.user.role == 'admin') {
          return UploadScreen(apiService: widget.apiService, user: widget.user);
        }
        return _screens[0];
      case 4:
        if (widget.user.role == 'admin') {
          return UsersScreen(apiService: widget.apiService);
        }
        return _screens[0];
      default:
        return _screens[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أكاديمية الألسن'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'المحتوى',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'الشات',
          ),
          if (widget.user.role == 'admin')
            BottomNavigationBarItem(
              icon: Icon(Icons.upload),
              label: 'رفع',
            ),
          if (widget.user.role == 'admin')
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'المستخدمين',
            ),
        ],
      ),
    );
  }
}

class HomeContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
            "https://via.placeholder.com/150?text=Alson+Logo",
            width: 120,
            height: 120,
          ),
          SizedBox(height: 30),
          Text(
            "مرحباً بك في أكاديمية الألسن",
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            "منصة التعلم الإلكتروني المتكاملة",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            child: Text("المحتوى التعليمي"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              minimumSize: Size(200, 50),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text("الدردشة التفاعلية"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              minimumSize: Size(200, 50),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}