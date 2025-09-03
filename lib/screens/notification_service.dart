import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<int> messageCount = ValueNotifier<int>(0);
  final ValueNotifier<int> contentCount = ValueNotifier<int>(0);
  final List<String> _notifications = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    messageCount.value = prefs.getInt('message_count') ?? 0;
    contentCount.value = prefs.getInt('content_count') ?? 0;
  }

  Future<void> addNotification(String message, {bool isMessage = false, bool isContent = false}) async {
    _notifications.insert(0, '${DateTime.now().toString()} - $message');
    
    if (isMessage) {
      messageCount.value++;
    }
    if (isContent) {
      contentCount.value++;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('message_count', messageCount.value);
    await prefs.setInt('content_count', contentCount.value);
  }

  Future<void> clearNotifications() async {
    _notifications.clear();
    messageCount.value = 0;
    contentCount.value = 0;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('message_count');
    await prefs.remove('content_count');
  }

  List<String> getNotifications() => _notifications;

  int getUnreadCount() => messageCount.value + contentCount.value;
}