import 'package:flutter/material.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/screens/content_screen.dart';
import 'package:alson_education/screens/chat_screen.dart';
import 'package:alson_education/screens/upload_screen.dart';
import 'package:alson_education/screens/users_screen.dart';
import 'package:alson_education/screens/admin_dashboard.dart';
import 'package:alson_education/screens/notifications_screen.dart';
import 'package:alson_education/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final app_user.AppUser user;
  final ApiService apiService;
  final Function() onLogout;
  final NotificationService notificationService;

  HomeScreen({
    required this.user,
    required this.apiService,
    required this.onLogout,
    required this.notificationService,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // يمكن إضافة منطق للتحميل التلقائي إذا لزم الأمر
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      case 5:
        return NotificationsScreen(notificationService: widget.notificationService);
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      controller: _scrollController,
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
            onPressed: () => _onItemTapped(1),
            child: Text("المحتوى التعليمي"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              minimumSize: Size(200, 50),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _onItemTapped(2),
            child: Text("الدردشة التفاعلية"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              minimumSize: Size(200, 50),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          if (widget.user.role == 'admin')
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminDashboard(
                    user: widget.user, 
                    apiService: widget.apiService, 
                    onLogout: widget.onLogout
                  ),
                ),
              ),
              child: Text("لوحة التحكم"),
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

  Widget _buildBadge(int count) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            _onItemTapped(5);
          },
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أكاديمية الألسن'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: widget.notificationService.messageCount,
            builder: (context, count, child) {
              return _buildBadge(widget.notificationService.getUnreadCount());
            },
          ),
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
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<int>(
              valueListenable: widget.notificationService.messageCount,
              builder: (context, count, child) {
                if (widget.notificationService.getUnreadCount() > 0) {
                  return Stack(
                    children: [
                      Icon(Icons.notifications),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            widget.notificationService.getUnreadCount().toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  );
                }
                return Icon(Icons.notifications);
              },
            ),
            label: 'الإشعارات',
          ),
        ],
      ),
    );
  }
}