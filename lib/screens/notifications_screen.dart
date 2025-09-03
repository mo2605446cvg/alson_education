import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alson_education/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  final NotificationService notificationService;

  NotificationsScreen({required this.notificationService});

  @override
  Widget build(BuildContext context) {
    final notifications = notificationService.getNotifications();

    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات'),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: () {
                notificationService.clearNotifications();
                Navigator.pop(context);
              },
              tooltip: 'مسح الكل',
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد إشعارات حالياً', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final parts = notifications[index].split(' - ');
                final timestamp = parts[0];
                final message = parts.length > 1 ? parts[1] : parts[0];
                
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.blue),
                    title: Text(message),
                    subtitle: Text(timestamp),
                    trailing: IconButton(
                      icon: Icon(Icons.close, size: 16),
                      onPressed: () {
                        // إزالة الإشعار الفردي
                        final updatedNotifications = List<String>.from(notificationService.getNotifications());
                        updatedNotifications.removeAt(index);
                        _saveNotifications(updatedNotifications);
                        // إعادة تحميل الصفحة
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationsScreen(notificationService: notificationService),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _saveNotifications(List<String> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notifications', notifications);
    // تحديث القائمة في service
    notificationService.getNotifications().clear();
    notificationService.getNotifications().addAll(notifications);
  }
}