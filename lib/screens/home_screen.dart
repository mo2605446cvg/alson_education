import 'package:flutter/material.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/screens/content_screen.dart';
import 'package:alson_education/screens/chat_screen.dart';
import 'package:alson_education/screens/users_screen.dart';
import 'package:alson_education/widgets/navigation_rail.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final ApiService apiService;

  HomeScreen({required this.user, required this.apiService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _navRailVisible = true;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _toggleNavRail() {
    setState(() => _navRailVisible = !_navRailVisible);
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return ContentScreen(apiService: widget.apiService, user: widget.user);
      case 2:
        return ChatScreen(apiService: widget.apiService, user: widget.user);
      case 3:
        if (widget.user.role == 'admin') {
          return UploadScreen(apiService: widget.apiService, user: widget.user);
        }
        return _buildHomeContent();
      case 4:
        if (widget.user.role == 'admin') {
          return UsersScreen(apiService: widget.apiService);
        }
        return _buildHomeContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            "https://via.placeholder.com/150?text=Alson+Logo",
            width: 120,
            height: 120,
          ),
          SizedBox(height: 30),
          Text(
            "مرحباً بك في أكاديمية الألسن",
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _onItemTapped(1),
            child: Text("المحتوى"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              minimumSize: Size(200, 50),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _onItemTapped(2),
            child: Text("الشات"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              minimumSize: Size(200, 50),
            ),
          ),
          SizedBox(height: 20),
          if (widget.user.role == 'admin')
            ElevatedButton(
              onPressed: () => _onItemTapped(4),
              child: Text("إدارة المستخدمين"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                minimumSize: Size(200, 50),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (_navRailVisible)
            NavigationRailWidget(
              user: widget.user,
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
              onLogout: () {
                // تنفيذ تسجيل الخروج
              },
            ),
          Expanded(child: _getCurrentScreen()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleNavRail,
        child: Icon(_navRailVisible ? Icons.menu_open : Icons.menu),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}