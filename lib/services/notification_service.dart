import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  ValueNotifier<int> messageCount = ValueNotifier<int>(0);
  ValueNotifier<int> contentCount = ValueNotifier<int>(0);
  List<String> notifications = [];

  NotificationService() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    messageCount.value = prefs.getInt('message_count') ?? 0;
    contentCount.value = prefs.getInt('content_count') ?? 0;
    
    // تحميل الإشعارات المحفوظة
    final savedNotifications = prefs.getStringList('notifications') ?? [];
    notifications = savedNotifications;
  }

  Future<void> addNotification(String message, {bool isMessage = false, bool isContent = false}) async {
    final notificationText = '${DateTime.now().hour}:${DateTime.now().minute} - $message';
    notifications.insert(0, notificationText);
    
    if (isMessage) {
      messageCount.value++;
    }
    if (isContent) {
      contentCount.value++;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('message_count', messageCount.value);
    await prefs.setInt('content_count', contentCount.value);
    await prefs.setStringList('notifications', notifications);
    
    // إشعار التحديث للواجهات
    messageCount.notifyListeners();
    contentCount.notifyListeners();
  }

  Future<void> clearNotifications() async {
    notifications.clear();
    messageCount.value = 0;
    contentCount.value = 0;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('message_count');
    await prefs.remove('content_count');
    await prefs.remove('notifications');
    
    messageCount.notifyListeners();
    contentCount.notifyListeners();
  }

  int getUnreadCount() => messageCount.value + contentCount.value;
}